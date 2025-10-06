# Campfire

Campfire is a web-based chat application. It supports many of the features you'd
expect, including:

- Multiple rooms, with access controls
- Direct messages
- File attachments with previews
- Search
- Notifications (via Web Push)
- @mentions
- API, with support for bot integrations

## Deploying with Docker

Campfire's Docker image contains everything needed for a fully-functional,
single-machine deployment. This includes the web app, background jobs, caching,
file serving, and SSL.

To persist storage of the database and file attachments, map a volume to `/rails/storage`.

To configure additional features, you can set the following environment variables:

- `SSL_DOMAIN` - enable automatic SSL via Let's Encrypt for the given domain name
- `DISABLE_SSL` - alternatively, set `DISABLE_SSL` to serve over plain HTTP
- `VAPID_PUBLIC_KEY`/`VAPID_PRIVATE_KEY` - set these to a valid keypair to
  allow sending Web Push notifications. You can generate a new keypair by running
  `/script/admin/create-vapid-key`
- `SENTRY_DSN` - to enable error reporting to sentry in production, supply your
  DSN here

For example:

    docker build -t campfire .

    docker run \
      --publish 80:80 --publish 443:443 \
      --restart unless-stopped \
      --volume campfire:/rails/storage \
      --env SECRET_KEY_BASE=$YOUR_SECRET_KEY_BASE \
      --env VAPID_PUBLIC_KEY=$YOUR_PUBLIC_KEY \
      --env VAPID_PRIVATE_KEY=$YOUR_PRIVATE_KEY \
      --env TLS_DOMAIN=chat.example.com \
      campfire

## Running locally with Docker Compose

For local testing with Docker Compose (useful for testing the Umbrel setup):

1. **Generate environment variables:**

        # Generate a random secret key
        openssl rand -hex 64

2. **Create `.env.local` file:**

        SECRET_KEY_BASE=<paste_your_generated_key>
        VAPID_PUBLIC_KEY=
        VAPID_PRIVATE_KEY=

3. **Create data directories:**

        mkdir -p local-data/storage local-data/redis

4. **Build and start:**

        docker-compose -f docker-compose.local.yml --env-file .env.local up --build

5. **Access Campfire at http://localhost**

**Access from other devices on your network:**

To access from your phone, tablet, or other computers on the same WiFi:

    # Find your Mac's IP address
    ipconfig getifaddr en0

Then visit `http://YOUR_IP_ADDRESS` from any device on your network (e.g., `http://192.168.1.123`).

Your data (database, uploaded files) will be persisted in the `local-data/` directory. When you stop and restart the containers, all your data will still be there.

**Useful commands:**

- Stop containers: `Ctrl+C` or `docker-compose -f docker-compose.local.yml down`
- View logs: `docker-compose -f docker-compose.local.yml logs -f`
- Reset all data: `rm -rf local-data/` (then recreate directories)

## Running in development

    bin/setup
    bin/rails server

## Worth Noting

When you start Campfire for the first time, you’ll be guided through
creating an admin account.
The email address of this admin account will be shown on the login page
so that people who forget their password know who to contact for help.
(You can change this email later in the settings)

Campfire is single-tenant: any rooms designated "public" will be accessible by
all users in the system. To support entirely distinct groups of customers, you
would deploy multiple instances of the application.
