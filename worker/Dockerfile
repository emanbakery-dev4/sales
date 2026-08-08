FROM node:22-alpine AS build
WORKDIR /app
RUN corepack enable
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY worker/package.json worker/package.json
RUN pnpm install --filter worker... --frozen-lockfile
COPY worker worker
RUN pnpm --filter worker build

FROM node:22-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app
RUN corepack enable
COPY --from=build /app/package.json /app/pnpm-lock.yaml /app/pnpm-workspace.yaml ./
COPY --from=build /app/worker/package.json worker/package.json
COPY --from=build /app/worker/dist worker/dist
COPY --from=build /app/worker/node_modules worker/node_modules
COPY --from=build /app/node_modules node_modules
USER node
EXPOSE 3001
CMD ["node", "worker/dist/index.js"]
