FROM node:26-alpine
WORKDIR /app
ENV NODE_ENV=production PORT=3000 DATA_DIR=/app/data
LABEL org.opencontainers.image.title="Savorly" \
      org.opencontainers.image.description="A self-hosted weekly meal planner for Unraid" \
      org.opencontainers.image.source="https://github.com/charliec94/greatgastby-mealplan"
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN corepack enable && corepack prepare pnpm@11.19.0 --activate && pnpm install --prod --frozen-lockfile
COPY server.js usda.js mealdb.js mailer.js ./
COPY public ./public
RUN apk add --no-cache su-exec && mkdir -p /app/data && chown node:node /app/data
# Unraid's per-container Tailscale hook needs root during container startup.
# The final command drops the Savorly app back to the unprivileged node user.
USER root
EXPOSE 3000
VOLUME ["/app/data"]
# Keep both the health check and startup command free of shell metacharacters;
# some Unraid hooks reconstruct container commands through eval.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["wget", "-q", "--spider", "http://127.0.0.1:3000/api/config"]
CMD ["su-exec", "node:node", "node", "server.js"]
