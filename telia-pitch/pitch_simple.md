Velocitee Vector — The Pitch, in Plain Words

Focus (per Telia mentor): aim at ordinary small and medium businesses that have
no IT staff. That is the biggest group of customers. Technical companies build
their own thing, so they are not the market. Everything below talks to the
non-technical owner.


ONE SENTENCE

Your own private office server, set up for you by Telia. You just plug it in,
and it turns on by itself. No IT person needed.


WHO IT IS FOR

Small businesses that hold sensitive information but have nobody technical:

- a law office with client contracts
- an accountant or bookkeeper with financial records
- a dental or medical clinic with patient files
- a small chain with a few branches

They all have the same kind of owner. Call her Kati. She runs a 12-person firm.
She is good at her job, not at computers.


KATI'S PROBLEM (say it the way she feels it)

"I need a safe place for my business files. Renting foreign cloud is expensive
and I do not really know where my clients' data ends up. Buying my own server
means hiring someone to install and babysit it, and I cannot afford that."

She is stuck between expensive cloud she does not trust and her own hardware she
cannot manage.


WHAT WE GIVE HER

A server that sets itself up. Telia sends the box. Someone plugs it into the
office router. It installs itself over the network, locks itself down, and comes
online. Kati clicks one button to approve it. That is the whole job.

- No technician visit.
- No setup, no command line, no manuals.
- Her data stays in her office, encrypted, not on someone else's cloud.


WHY IT WORKS NOW

The router is already in her office, and Telia already sends her a bill. We are
not asking her to buy anything new or switch providers. We turn the router she
already has into the thing that installs and manages her server.


WHY TELIA SHOULD CARE (the money)

- Today a customer pays about 40 euros a month for a broadband line.
  With Velocitee Vector she pays about 120 euros a month for a managed server.
  That is roughly three times the revenue, from a customer Telia already has.

- She stops leaving. You do not switch providers when your whole business runs
  on the box they gave you. Churn drops toward zero.

- No R&D cost for Telia. Velocitee builds the software. Telia sells it and bills
  it.


WHY AIM AT NON-TECHNICAL BUSINESSES (the strategy in one line)

They are the largest group, they have no other option, and they will pay to not
think about it. Technical companies build their own, so chasing them is wasted
effort. We win by being the easy button for everyone else.


THE 30-SECOND SPOKEN VERSION

"Small businesses need their own secure server, but they have no IT people and
they do not trust foreign cloud with client data. Telia already has a router in
every one of these offices. We turn that router into an easy button: plug a
server in, the owner clicks approve, and it installs itself and comes online,
encrypted, in the office. For the business it is finally affordable and simple.
For Telia it turns a 40-euro line into a 120-euro service that customers never
cancel. Same customers, three times the revenue, near-zero churn."


LIVE PROOF (what the demo shows)

A blank server becomes a secure, running office server after one click, with
nobody touching a keyboard on the machine. Run sheet: demo_steps.md.


PROTOTYPE DEMO VS. PRODUCTION REALITY (How it actually works)

Judges often ask: "Is this real or simulated?" Here is the plain, honest answer:

What we built for today's prototype (Live on macOS):
- We run both sides on this single laptop to show how lightweight it is.
- The router side: an orchestrator daemon running on macOS loopback (192.168.100.1),
  mimicking the carrier router switch, VLAN isolation, and API.
- The server side: an emulated edge server node (192.168.100.50) with authentic
  SSH access, container runtime, and web dashboards.
- The workflow: real HTTP API authorization, HMAC claim validation, automated
  quarantine transition, and real SSH terminal access.
- Total memory used across the entire simulation: under 30 MB.

What happens in real life (Production rollout):
1. The Box Arrives: Telia ships a standard, off-the-shelf microserver (or the
   customer buys their own certified hardware).
2. Physical Cable: The customer plugs an ethernet cable from the server into Port 4
   of their existing Telia office router (CPE).
3. Network Boot (PXE / Netboot): The server powers on blank. The router's built-in
   agent catches the machine via DHCP, places it on an isolated Quarantine VLAN,
   and streams the locked down OS directly across the wire over TLS.
4. Cryptographic Claim: The owner clicks "Approve" on the Telia portal. The router
   flips the switch port from Quarantine to the private Trusted Office LAN, seals
   the disk with TPM 2.0 encryption, and launches the sovereign applications.
   Zero truck rolls. Zero USB sticks. Done in under 3 minutes.

