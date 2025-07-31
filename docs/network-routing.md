# Network Routing and Packet Flow

## Overview

This document explains how network routing works in cloud/VPS environments, particularly the unusual routing setup where servers get public IPs directly but use private gateways.

## Example Routing Table Analysis

Given this routing table from a cloud server:

```
default via 172.31.1.1 dev eth0 proto dhcp src 91.99.148.215 metric 100
172.31.1.1 dev eth0 proto dhcp scope link src 91.99.148.215 metric 100
185.12.64.1 via 172.31.1.1 dev eth0 proto dhcp src 91.99.148.215 metric 100
185.12.64.2 via 172.31.1.1 dev eth0 proto dhcp src 91.99.148.215 metric 100
```

And IP configuration:
```
eth0: inet 91.99.148.215/32
```

## How This Works

### Key Components

- **Server IP**: 91.99.148.215/32 (public IP, /32 = no subnet)
- **Gateway**: 172.31.1.1 (private IP, different subnet)
- **Interface**: eth0

### The Problem

Normally, this shouldn't work because:
1. Server has 91.99.148.215/32 (subnet contains only itself)
2. Gateway is 172.31.1.1 (completely different network)
3. Standard networking rules: can't directly reach IPs outside your subnet

### The Solution: `scope link`

The critical line is:
```
172.31.1.1 dev eth0 scope link
```

**`scope link` means**: "This IP is directly reachable at layer-2 (Ethernet), ignore subnet rules"

## Packet Flow Details

### Outgoing Traffic (Server → Internet)

**Why do we try to reach 172.31.1.1?**
Because it's your default gateway! When you want to reach anything on the internet (like 8.8.8.8), your routing table says:
```
default via 172.31.1.1 dev eth0
```
This means: "To reach 8.8.8.8, first send the packet to 172.31.1.1"

**Does the kernel really check subnet membership?**
YES! Here's the exact process:

1. **You want to reach 8.8.8.8**
2. **Routing table says**: "Send via 172.31.1.1"
3. **Kernel must decide**: "How do I reach 172.31.1.1?"
   - Checks routing table again
   - Finds: `172.31.1.1 dev eth0 scope link`
   - This means: "Send directly on eth0" (don't use another gateway)
4. **Now kernel asks**: "What's the MAC address of 172.31.1.1?"
   - Time for ARP!

#### Detailed Step-by-Step Process

1. **Application creates packet**:
   ```
   Source: 91.99.148.215:45678
   Dest: 8.8.8.8:53
   ```

2. **Kernel routing decision**:
   - Checks routing table for 8.8.8.8
   - Matches default route → send via 172.31.1.1

3. **Gateway resolution**:
   - Need to reach 172.31.1.1
   - `scope link` route says: send directly on eth0
   - Skip normal subnet check

4. **ARP resolution**:
   - Broadcast: "Who has 172.31.1.1?"
   - Gateway responds with its MAC address
   - Provider ensures this works with proxy ARP

5. **Ethernet frame**:
   ```
   Ethernet Header:
     Source MAC: [server MAC]
     Dest MAC: [gateway MAC]
   
   IP Packet:
     Source: 91.99.148.215:45678
     Dest: 8.8.8.8:53
   ```

6. **Gateway forwards to internet**:
   - No NAT needed (server already has public IP)
   - Just routes packet to next hop

### Incoming Traffic (Internet → Server)

1. **Internet packet arrives**:
   ```
   Source: 203.0.113.5:55234
   Dest: 91.99.148.215:22
   ```

2. **Provider's edge router**:
   - Knows 91.99.148.215 is behind gateway 172.31.1.1
   - Routes to that gateway

3. **Gateway delivery**:
   - Uses ARP/layer-2 to find server's MAC
   - Delivers packet unchanged

4. **Server receives**:
   - eth0 gets packet for 91.99.148.215:22
   - Kernel delivers to SSH daemon

## ARP (Address Resolution Protocol)

### How ARP Works

ARP (Address Resolution Protocol) finds MAC addresses for IP addresses:

**1. ARP Request (Broadcast)**
```
Ethernet Frame:
  Source MAC: 92:00:06:4b:be:d4 (you)
  Dest MAC: FF:FF:FF:FF:FF:FF (BROADCAST!)
  Type: ARP

ARP Packet:
  "Who has 172.31.1.1? Tell 91.99.148.215"
```

**2. This broadcast goes to EVERYONE on the Ethernet segment**
- Every device receives it
- Each checks: "Is 172.31.1.1 my IP?"
- Only the gateway says "Yes!"

**3. ARP Reply (Unicast)**
```
Ethernet Frame:
  Source MAC: aa:bb:cc:dd:ee:ff (gateway)
  Dest MAC: 92:00:06:4b:be:d4 (back to you)
  Type: ARP

ARP Packet:
  "172.31.1.1 is at aa:bb:cc:dd:ee:ff"
```

**4. Your kernel caches this**
```
ARP Cache:
172.31.1.1 -> aa:bb:cc:dd:ee:ff
```

### The Normal Subnet Check (that gets bypassed)

Normally, before doing ARP, kernel checks:
```python
def can_reach_directly(my_ip, my_mask, target_ip):
    my_network = my_ip & my_mask
    target_network = target_ip & my_mask
    return my_network == target_network

# Normal case:
can_reach_directly("91.99.148.215", "255.255.255.255", "172.31.1.1")
# Returns: False! Different networks!
```

But the `scope link` route says: "Skip this check for 172.31.1.1 - just ARP for it anyway"

### Why This ARP Works

Normally, you can only ARP for IPs in your subnet. Here:
- Your subnet: 91.99.148.215/32 (only yourself)
- Gateway: 172.31.1.1 (different network)

The provider ensures:
1. **Your server and gateway are on the same physical Ethernet segment** (or VLAN)
2. **Gateway is configured to respond to ARP from your "wrong" subnet**
3. **The special route bypasses the subnet check**

Without these three things, you'd get "Network unreachable" when trying to use 172.31.1.1 as your gateway!

## DNS Resolution Process

Before any routing decisions happen, domain names must be resolved to IP addresses.

**How does your machine know you want to reach 8.8.8.8 when typing google.com?**

### Complete DNS Flow

**1. You type `curl google.com`**

**2. Application calls DNS resolver**:
- Checks local DNS cache first
- If not cached, needs to query DNS server

**3. Find DNS server**:
- Looks at `/etc/resolv.conf`:
```
nameserver 185.12.64.1
nameserver 185.12.64.2
```
- These are the DNS servers from your routing table!

**4. DNS query packet**:
```
Source: 91.99.148.215:53281 (random port)
Dest: 185.12.64.1:53 (DNS)
Query: "What's the IP for google.com?"
```

**5. Routing the DNS query**:
- Kernel checks routing table for 185.12.64.1
- Finds: `185.12.64.1 via 172.31.1.1`
- Sends via gateway (same ARP process we discussed)

**6. DNS server responds**:
```
Source: 185.12.64.1:53
Dest: 91.99.148.215:53281
Answer: "google.com is 142.250.191.14"
```

**7. Now you know the IP**:
- Application gets: google.com = 142.250.191.14
- Caches this mapping locally

**8. Make the actual request**:
```
Source: 91.99.148.215:45678
Dest: 142.250.191.14:80 (HTTP)
```

### The Complete Flow
```
google.com → DNS lookup → 142.250.191.14 → routing decision → via 172.31.1.1
```

DNS resolution happens **before** routing - your machine needs to convert the domain name to an IP address first, then it can make routing decisions about how to reach that IP.

## Special Routes

```
185.12.64.1 via 172.31.1.1 dev eth0
185.12.64.2 via 172.31.1.1 dev eth0
```

These are your provider's DNS servers. Explicit routes ensure:
- DNS always goes through correct path
- Prevents DNS hijacking
- Redundant routing (would work via default anyway)
- DNS resolution works even if default route fails

## Why This Architecture

### Advantages
- **No NAT overhead**: Direct public IP = better performance
- **Provider control**: Can manage routing/filtering at gateway
- **DDoS protection**: Filter attacks before reaching server
- **Flexibility**: Easy to move IPs between servers
- **True public IP**: No port forwarding complications

### How It Works
- **Layer-2 connectivity**: Server and gateway on same Ethernet segment
- **Layer-3 routing**: Different IP subnets connected by special configuration
- **Provider magic**: Edge routers know which gateway serves which public IPs

## Routing Table Breakdown

| Route | Meaning |
|-------|---------|
| `default via 172.31.1.1` | Send all unknown destinations to gateway |
| `172.31.1.1 dev eth0 scope link` | Gateway is directly reachable, skip subnet rules |
| `185.12.64.1/2 via 172.31.1.1` | DNS servers via gateway (redundant but explicit) |
| `src 91.99.148.215` | Use this IP as source for outgoing packets |

This setup allows servers to have real public IPs while still giving providers routing control through private gateway infrastructure.