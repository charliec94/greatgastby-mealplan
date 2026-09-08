FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production PORT=3000 DATA_DIR=/app/data
LABEL org.opencontainers.image.title="Savorly" \
      org.opencontainers.image.description="A self-hosted weekly meal planner for Unraid" \
      org.opencontainers.image.source="https://github.com/charliec94/greatgastby-mealplan"
COPY package.json server.js usda.js mealdb.js ./
COPY public ./public
RUN mkdir -p /app/data && chown -R node:node /app
USER node
EXPOSE 3000
VOLUME ["/app/data"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["node", "-e", "fetch('http://127.0.0.1:3000/api/config').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"]
CMD ["node", "server.js"]
