Credit Rating based on Account data
===

Aim is to obtain bank account movements and translate those into a credit
rating. This is only a demostration and utilises [Figo](https://figo.io)
for obtaining bank account data.

Since Figo requires registration in order to fully utilise their service,
you should first obtain a fully working API credentials. Failing that,
this demo application tries to do as much as possible with the
[demo credentials](http://docs.figo.io/v2/index.html).

Features
---

  1. Credit Rating History
  2. Bank Account data import
  3. Bank Account transaction data automatic import
  4. Credit Rating Badge
  5. [Figo](https://figo.io) support

Local testing
---

Install [Docker](https://docker.com) and do once:

    docker volume create --name=credratdb
    docker volume create --name=credratenv
    docker network create credratnet

Then build the docker image and start it:

    docker-compose build
    docker-compose up

The ```up``` command will start the web server, the migration server
and the import server. The migration server will run once and ensure the
database has been migrated. Import server runs every ten minutes and imports
account data from Figo.

Now you should be able to access localhost:

    open -a Firefox http://localhost:3000

First thing to do is registration. This can be any email address and
it won't send an emails (it will send emails if you have an Mandrill
API token at hand).

After confirming your email, login with the email.

Now you need to wait 10 minutes until the import task retrieves your
"account data" from Figo. This will be test data but suffices to demostrate
how the application works.

After ten minutes, you can view account data, rating and generate a badge.
Again, this is all very basic and does not aim for completion. It just
demostrates how to use the Figo API.

Bootstrapping
---

Need to run the following tasks to initialise the app:

    rake import:figo_supported_stuff

After that, the following tasks should be run regularly:

    rake import:figo_supported_stuff # once a day
    rake import:from_figo # every 10 mins
    rake ratings:compute # every 10 mins

These takes ensure things are up-to-date and that transactions are
retrieved as soon as they become available.

License
---

MIT
