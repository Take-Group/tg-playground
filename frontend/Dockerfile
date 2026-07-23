FROM oven/bun:1.3.14-alpine AS runtime

WORKDIR /app
RUN apk upgrade --no-cache && chown bun:bun /app
USER bun

FROM runtime AS base

# Install dependencies (cached layer)
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Copy source
COPY --chown=bun:bun . .

# Production build
FROM base AS build
RUN bun run build

# Production runner
FROM runtime AS runner

ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

COPY --chown=bun:bun --from=build /app/.next/standalone ./
COPY --chown=bun:bun --from=build /app/.next/static ./.next/static
COPY --chown=bun:bun --from=build /app/public ./public

USER bun
EXPOSE 3000
CMD ["bun", "server.js"]
