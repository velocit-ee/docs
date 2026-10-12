Velocitee Vector — Demo Run Sheet (plain language)

Who we are pitching to: a small business owner with no IT person. A lawyer, a
dentist, an accountant, a small shop with a few branches. They are not technical.
Keep every spoken line in plain words. The screen does the technical part.

Total time on stage: about 90 seconds. Five short beats.


BEFORE YOU WALK ON STAGE (one-time setup)

Run this once, a few minutes before you present. It starts everything on your
laptop:

    bash core/vector/telia/scripts/run_full_system.sh

That opens four things:

- The management console, at http://localhost:3000
  This is the screen you drive the demo from.

- The router page, at http://localhost:8088 (or http://192.168.100.1:8088)
  This is the office router.

- The finished server, at http://localhost:8081 (or http://192.168.100.50:8081)
  This is the business server, once it is live.

- The server's login, over SSH: ssh ubuntu@192.168.100.50
  Proof that it is a real machine.

Optional, for the most realistic version with real IP addresses (asks for your
Mac password once):

    bash core/vector/telia/scripts/setup_edge_network.sh

Leave the console (http://localhost:3000) open on screen. You are ready.


THE FIVE BEATS

Beat 1 — Say what it is (15 seconds)

"Every business already has a router in the office from Telia. Today, if you want
your own server, you have to pay a specialist to come set it up. With this, you
just plug the server in. Telia turns it on for you, over the network,
automatically. No technician, no cables to configure, no waiting."

Beat 2 — Show how small it is (10 seconds)

Point at the top of the console. It shows the router using about 27 MB of memory.

"This runs inside the router the customer already has. It does not need new
hardware and it does not slow their internet down."

Beat 3 — Show the new server waiting (15 seconds)

On the console you will see Port 4 flagged with an unclaimed server.

"Someone plugged a new server into the office. Right now it is locked in a
holding area. It cannot touch any company data or the internet until the owner
says yes. That is the safety part: a stranger's laptop cannot sneak on."

Beat 4 — Approve it and watch it build (30 seconds)

Click "Authorize and Deploy Appliance." Pick the profile first if you want:
- Plain Ubuntu server: the everyday product for any business.
- Legal office suite: the example scenario, with secure files, database, backup.
Watch the bar move through the steps: verify, install, encrypt, go live.

"One click. It checks the hardware, installs the operating system over the
network, encrypts the disk so a stolen drive is useless, and moves it onto the
trusted office network. The owner did nothing but approve it."

Beat 5 — Prove it is real (20 seconds)

Click "Open Server Dashboard" (it opens http://localhost:8081). Then, in a
terminal, log in:

    ssh ubuntu@192.168.100.50
    uname -a

"There it is: a real, running server at its own address, encrypted and online.
From a box in a cupboard to a working office server, hands-off. That is
Velocitee Vector."


RESET BETWEEN RUNS

Puts the server back to "waiting for approval" so you can demo again in one
second:

    curl -s -X POST http://localhost:3000/api/v1/reset


STOP EVERYTHING AFTER

    bash core/vector/telia/scripts/teardown_demo.sh


IF SOMETHING GOES WRONG ON STAGE

- Console shows nothing, or the backend is not running: the console still works.
  Click Authorize and it will play the full deployment on its own. The audience
  sees no difference.

- The ssh step fails: skip it. The browser dashboard at http://localhost:8081
  already proves the server is live. Do not fight it.

- Real IPs are not set up: use the localhost links above. They show the exact
  same screens.


IF A JUDGE ASKS "HOW DOES IT ACTUALLY WORK?" (only if asked)

One sentence each. Do not lead with this.

- Is it secure? The new server is quarantined until approved, and approval is a
  signed one-time token, so a rogue machine cannot boot or reach the network.

- Where does the data live? On the server in the office, disk-encrypted. It does
  not have to leave the country, which helps with GDPR and NIS2.

- Does it fit real router hardware? Yes. The software footprint is tens of
  megabytes, sized for the Telia router the customer already has.

- What if the office loses the machine? The disk is encrypted, so the data on a
  stolen drive is unreadable.
