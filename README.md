# Savorly

A small, polished meal-planning app built for a home server. Plan all seven days, track calories and protein, adjust servings, and get one consolidated shopping list grouped by aisle.

## Features

- Daily calorie and protein goals
- Weekly planner including Saturday and Sunday
- Six photographed sample recipes
- Dedicated one-pot batch meals yielding 6–8 servings for 3–5 days
- Personal recipe creation with ingredients, instructions, storage notes, and photos
- Draft, Tried, and Verified recipe workflow with 1–5 star ratings and cooking notes
- Editing and deletion for personal recipes
- Complete cooking methods and storage guidance for all starter recipes
- Automatic per-serving calorie and protein calculation from personal-recipe ingredient totals
- Server-side USDA FoodData Central ingredient search with a built-in demo-key fallback
- TheMealDB recipe discovery with photos, ingredients, methods, and local draft saving
- Guided USDA nutrition completion for imported recipes, including weight conversion and planner-ready gating
- Responsive light and dark themes with saved device preference
- Smart seven-day plan proposals with saved meal, protein, and batch preferences
- Favorite and “don’t suggest” recipe controls
- One-click meal swaps and remaining batch-portion tracking
- Goal-aware planning with 3–6 eating slots, half portions, and protein-efficient snacks
- Daily calorie/protein gap indicators and a “Fix this day” action
- Real calendar weeks with previous/next navigation and copy-last-week
- Prepared batch inventory and eaten/skipped meal tracking
- Pantry-aware shopping, manual items, printing, and device sharing
- SMTP delivery of the remaining shopping list to a fixed private recipient
- Recipe search plus dietary, allergy, dislike, and cooking-time preferences
- Weekly planning insights and complete JSON backup/restore
- Serving-aware nutrition and ingredient scaling
- Automatically consolidated, aisle-grouped shopping list
- Persistent shopping checks and plan data in `data/state.json`
- Responsive desktop and mobile layout
- No third-party runtime dependencies

## Run with Docker Compose

```bash
docker compose pull
docker compose up -d
```

Open `http://YOUR-SERVER-IP:3000`. Planner data is stored in the local `./data` folder and survives container upgrades.

For local development from source, use `docker compose up -d --build` instead.

## Unraid setup

### Docker Compose Manager

1. Copy this project to `/mnt/user/appdata/savorly/app`.
2. In the Compose Manager plugin, add a stack using `docker-compose.yml`.
3. Start the stack and open `http://YOUR-UNRAID-IP:3000`.

### Published container image

The ready-to-run image is:

```text
ghcr.io/charliec94/greatgastby-mealplan:latest
```

Every update to `main` is tested and published automatically for both Intel/AMD and ARM64 systems. Version tags such as `v1.1.0` also produce fixed version images.

The first time GitHub publishes the package, its visibility may default to private. In GitHub, open the repository's package, choose **Package settings**, and change its visibility to **Public** so Unraid can pull it without registry credentials.

### Unraid user template

The ready-made template is [`unraid/savorly.xml`](unraid/savorly.xml). Copy it to:

```text
/boot/config/plugins/dockerMan/templates-user/my-savorly.xml
```

Then open **Docker → Add Container**, select **Savorly** from **User Templates**, review the appdata path and port, and add your USDA key if desired.

### Manual container

Build the image from this folder, then create a container with:

- Container port: `3000`
- Host port: `3000` (or any free port)
- Persistent path: `/mnt/user/appdata/savorly/data` → `/app/data`
- Restart policy: `unless-stopped`

The app has no login and is intended for a trusted home network. Put it behind your existing authenticated reverse proxy before exposing it to the internet.

### Unraid per-container Tailscale

The published image is compatible with Unraid's per-container Tailscale hook. It starts as root because the hook needs startup privileges, then `su-exec` drops the Savorly server to the unprivileged `node` user. Both the container command and health check avoid shell-sensitive formatting that can break wrappers which reconstruct commands through `eval`.

The final image command is simply:

```text
["su-exec", "node:node", "node", "server.js"]
```

## Release pipeline

The workflow in `.github/workflows/container.yml` runs the automated tests, checks application syntax, verifies the Docker build, and then publishes a multi-platform image to GitHub Container Registry. Pull requests are tested but never published. Dependabot checks the Docker base image and workflow actions monthly.

Before relying on a release, confirm **Test and publish container** is green in the repository's **Actions** tab. For a stable release, create a Git tag such as `v1.1.0`; Unraid can stay on `latest` or pin that exact version.

## Run locally without Docker

Node.js 20 or newer is the only requirement.

```bash
npm start
```

Then open `http://localhost:3000`.

## Test

```bash
npm test
npm run build
```

Recipe photos load from Unsplash, so an internet connection is required for images. The planner itself continues to work if images are unavailable.

## Recipe quality and future sources

The included recipes are starter concepts for testing the planner, not independently kitchen-tested recipes. Treat their nutrition as an estimate until the ingredients are weighed and checked against a nutrition database.

A production recipe should record its original source, cooking instructions, date tested, personal rating, storage guidance, and verified per-serving nutrition. USDA FoodData Central is a strong source for ingredient-level nutrition. A recipe provider such as Edamam can provide ongoing discovery, but its attribution and caching rules must be followed and API credentials should be stored only on the server.

Personal recipes, ratings, verification status, and notes are saved alongside the planner in `data/state.json`. Back up this folder with the rest of your Unraid appdata.

When adding a personal recipe, each ingredient line can include its total calories and protein. Savorly adds those ingredient totals and divides them by the recipe yield, showing the calculated per-serving nutrition before you save.

## Optional APIs

All API calls should go through the Node server so credentials never reach the browser. Copy `.env.example` to `.env` and set keys there; `.env` is ignored by Git. Docker Compose passes these values into the container.

- `USDA_API_KEY`: ingredient nutrition lookup through USDA FoodData Central
- `MEALDB_API_KEY`: TheMealDB recipe discovery; defaults to the free development key `1`
- `RECIPE_API_KEY`: reserved for another future licensed recipe-discovery provider

### Email shopping lists with SMTP

Add these container variables in Unraid:

- `SMTP_HOST`: your mail provider's SMTP hostname
- `SMTP_PORT`: normally `465` for implicit TLS or `587` for STARTTLS
- `SMTP_SECURE`: `true` with port 465; normally `false` with port 587
- `SMTP_REQUIRE_TLS`: optionally set `true` to require STARTTLS
- `SMTP_USER`: your SMTP username; leave blank only for a trusted internal relay
- `SMTP_PASS`: your SMTP password or app password
- `SMTP_FROM`: the sender address accepted by the provider
- `SMTP_TO`: the fixed address that receives your lists

After applying the container changes, open **Shopping list → Email list**. Savorly emails unchecked items that are not marked as already in the pantry, grouped by aisle. The password and recipient remain server-side. Sending is limited to once every 30 seconds, remote attachments are disabled, and the browser cannot select an arbitrary recipient.

The recipe editor includes USDA FoodData Central ingredient search. Searches stay server-side and use `USDA_API_KEY` when configured, or USDA's rate-limited `DEMO_KEY` for testing. Results are cached for 15 minutes, requests are validated and time out safely, and `/api/config` reports only the integration mode—never the credential itself.

The recipe library's **Find new recipes** button searches TheMealDB. Its free key is intended for development and personal projects. Imported recipes include the source photo, ingredients, method, and attribution, but TheMealDB does not supply nutrition. Savorly therefore saves them as excluded drafts until you edit them and calculate nutrition with USDA.
