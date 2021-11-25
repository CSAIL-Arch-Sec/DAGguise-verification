# README


## Environment Setup

You can either use Docker or Vagrant+VirtualBox.

For docker:
1. Run `docker-compose up -d` to build up the container.
2. Run `docker-compose exec dagguise-formal bash` to login to the container.
3. Run `docker-compose down --rmi all` to clean up. (`docker system prune` can further clean up the cache, including your cache for other projects.)

For Vagrant+VirtualBox:
1. Run `vagrant up ` to build up the virtual machine.
2. Run `vagrant ssh` to login to the virtual machine.
3. Run `vagrant destroy` to clean up.


### Run Verification

In the container or virtual machine:
1. `cd /DAGguise-noninterference`
2. `raco test src/checkSecu.rkt`

Further more, you can try
1. `raco test ++arg --cycle ++arg 5 src/checkSecu.rkt` to see 5-induction does not work. (Take 5 mins)
2. `raco test ++arg --cycle ++arg 6 src/checkSecu.rkt` or simply `raco test src/checkSecu.rkt` to see 6-induction works. (Take 40 mins)


## Name Conventions

- change state: transitiveVerb-object! (e.g. set-cpu-reg!); object-intransitiveVerb!
- just a logic from state: object-info

