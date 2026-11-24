# Week 12 Reflection - Infrastructure as Code with OpenTofu

**1. What's the difference between declarative and imperative infrastructure management?**

Imperative is me running the steps myself: `docker network create`, then `docker volume create`, then a long `docker run` with all the flags, in the right order. If I run it twice or something is half-done, I have to sort it out myself. Declarative is just writing down what I want to exist: a network, a web container on a port, a database with a volume. OpenTofu figures out what to create, change or delete to get there. I noticed this most when I re-ran plans: if nothing had changed it did nothing, and when only one container was missing it only planned to make that one container. I never wrote any "how" steps.

**2. What role did OpenTofu state play in this exercise?**

State is how OpenTofu knows which real Docker objects belong to which resources in my code. It's basically a map from `docker_container.db` to an actual container ID. Without it, OpenTofu couldn't tell the difference between "I need to create this" and "this already exists, leave it alone", and `tofu destroy` wouldn't know what to delete. I could watch it grow through `tofu state list`: 3 resources after the starter, 8 after the full stack, and nothing after destroy. In the drift test, OpenTofu refreshed state against Docker, saw the DB container ID it had recorded was gone, and planned to create a new one.

**3. Why did the PostgreSQL data survive removal of the database container during the drift test?**

The data wasn't stored in the container. It was in the named volume `sdi4213-week12-pgdata`, which is its own resource with its own lifecycle. `docker rm -f sdi4213-week12-db` only removed the container. `docker volume ls` right afterwards still showed the volume. When `tofu apply` made a new container (the ID changed from `df6de42dae8f` to `a9aa9c4529f3`), it mounted the same volume, Postgres found its existing data, and my `milestone` row ("Week 12 persistence test") was still there in Adminer. The container is disposable; the volume is where the data actually lives.

One thing I ran into: the resource hints say to mount the volume at `/var/lib/postgresql/data`, but the postgres 18 image won't start like that anymore. It crash-looped with a message saying 18+ stores data in a version folder (`/var/lib/postgresql/18/docker`) and wants the mount at `/var/lib/postgresql`. I changed the mount path in `main.tf`, and the plan showed it as a replacement of only the DB container.

**4. Why can a sensitive variable still create security concerns for local state?**

`sensitive = true` only hides the value in the CLI. The plan showed `env = (sensitive value)` and `tofu show` didn't print my password. But OpenTofu still has to pass the real password to Docker, and it saves it in `terraform.tfstate` in plain text. I checked, and the password is in the state file. So anyone who gets the state file gets the password. That's why `*.tfstate` and `terraform.tfvars` are in `.gitignore`. On a real team you'd keep state in a locked-down remote backend with encryption, and pull the secret from a secrets manager instead of a local file.

**5. What did `tofu plan` show after you changed `web_port`, and why is reviewing that plan useful before apply?**

Changing `web_port` from 8080 to 8088 showed `docker_container.web must be replaced`, with `external = 8080 -> 8088 # forces replacement`, `Plan: 1 to add, 0 to change, 1 to destroy`, and `portal_url` changing to `http://localhost:8088`. I expected an in-place update, but Docker can't change the published port on an existing container, so it gets destroyed and recreated. That means a little downtime.

Reviewing the plan actually saved me once during this lab. When I planned the full stack, I'd left my tfvars with `web_port = 8088` from an earlier try. The plan said "6 to add, 1 to destroy" instead of the "5 to add, 0 to destroy" I expected. Because I read it first, I caught that it was about to replace the web container, fixed the variable, re-planned, and got the clean 5 adds before applying. If that had been the database without a volume, applying blindly could have lost data.
