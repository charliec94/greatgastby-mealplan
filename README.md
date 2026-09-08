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
- Smart seven-day plan proposals with saved meal, protein, and batch preferences
- Favorite and “don’t suggest” recipe controls
- One-click meal swaps and remaining batch-portion tracking
- Goal-aware planning with 3–6 eating slots, half portions, and protein-efficient snacks
- Daily calorie/protein gap indicators and a “Fix this day” action
- Real calendar weeks with previous/next navigation and copy-last-week
- Prepared batch inventory and eaten/skipped meal tracking
- Pantry-aware shopping, manual items, printing, and device sharing
- Recipe search plus dietary, allergy, dislike, and cooking-time preferences
- Weekly planning insights and complete JSON backup/restore
- Serving-aware nutrition and ingredient scaling
- Automatically consolidated, aisle-grouped shopping list
- Persistent shopping checks and plan data in `data/state.json`
- Responsive desktop and mobile layout
- No third-party runtime dependencies

## Run with Docker Compose

```bash
docker compose up -d --build
```

Open `http://YOUR-SERVER-IP:3000`. Planner data is stored in the local `./data` folder and survives container upgrades.

## Unraid setup

### Docker Compose Manager

1. Copy this project to `/mnt/user/appdata/savorly/app`.
2. In the Compose Manager plugin, add a stack using `docker-compose.yml`.
3. Start the stack and open `http://YOUR-UNRAID-IP:3000`.

### Manual container

Build the image from this folder, then create a container with:

- Container port: `3000`
- Host port: `3000` (or any free port)
- Persistent path: `/mnt/user/appdata/savorly/data` → `/app/data`
- Restart policy: `unless-stopped`

The app has no login and is intended for a trusted home network. Put it behind your existing authenticated reverse proxy before exposing it to the internet.

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
- `RECIPE_API_KEY`: reserved for a future licensed recipe-discovery provider

The recipe editor includes USDA FoodData Central ingredient search. Searches stay server-side and use `USDA_API_KEY` when configured, or USDA's rate-limited `DEMO_KEY` for testing. Results are cached for 15 minutes, requests are validated and time out safely, and `/api/config` reports only the integration mode—never the credential itself.
