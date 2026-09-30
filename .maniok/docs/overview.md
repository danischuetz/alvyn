# Alvyn architecture

Alvyn is a TypeScript library for event history in PostgreSQL. Applications record events, replay them into state, and consume the history. This repository also contains a bank-account example and a product website.

![Alvyn System Context](embed:alvyn-context)

![Alvyn Containers](embed:alvyn-containers)

## Alvyn Library

The package exports one entry point, `alvyn`, from `src/index.ts`. Its principal runtime API is `EventStore`. It also exports `migrateEventStore`, `defineAggregate`, `defineSnapshot`, `defineProjection`, public types, error classes, and `MAX_READ_EVENTS_PAGE_LIMIT`. The package export in `package.json` points to the built `dist/index.js` and its type declarations.

Client code supplies a `pg.Pool`, creates an `EventStore`, and calls `setup()` before it reads or writes events. A deployment job can call `migrateEventStore({ pool })` instead. Client replicas can then use `migrationMode: "verify"`. Clients define event maps and reducers with `defineAggregate`. They pass the store to aggregate `append` and `load` methods. The example server uses these imports and calls in `examples/example-alvyn-full-stack-app/server.ts` and `server/aggregates/`.

Clients select stream IDs, expected versions, and optional idempotency keys. They supply projection handlers, outbox handlers, and any encryption secrets that they need. They manage external effects and subscription cursors. The library runs in the importing Node.js process. The npm package boundary does not create a separate service. PostgreSQL hosts the schema, including `events`, `idempotency_keys`, `outbox`, `crypto_keys`, `projections`, and `schema_version` (`src/schema/run-migrations.ts`).

![Alvyn Library Components](embed:alvyn-library-components)

`EventStore` coordinates the library API (`src/event-store.ts`). `Schema` applies or verifies migrations (`src/schema/`). `Stream` checks versions and idempotency keys, writes events and outbox entries, and reads event pages (`src/stream/`). `Aggregate` replays client reducers (`src/aggregate/`). `Snapshot` stores calculated state as an event in the source stream (`src/snapshot/`).

`Subscription` reads committed events, then waits for notifications or a polling interval (`src/subscription/`). `Projection` calls client handlers and records their positions (`src/projection/`). `Outbox` passes claimed entries to a client handler (`src/outbox/`). `Crypto` encrypts selected fields and manages per-entity keys (`src/crypto/`). `Upcaster` transforms event data during reads (`src/upcaster/`). These components run with the library in the client process.

## Example Alvyn Full Stack App Server

The example server owns the `/graphql` endpoint and creates its own `pg.Pool` and `EventStore` (`examples/example-alvyn-full-stack-app/server.ts`). Its GraphQL API handles account queries, mutations, and subscriptions. The Bank Account Aggregate defines account status from account events. The Transaction Aggregate and Balance Snapshot define transaction events and a derived balance (`server/aggregates/`). The server imports the library through `alvyn` and uses aggregate handles, a registered snapshot, and event subscriptions.

![Example Server Components](embed:example-server-components)

## Example Alvyn Full Stack App Client

The React account components collect account commands and display balances and transactions (`examples/example-alvyn-full-stack-app/app/components/`). The GraphQL client sends queries and mutations to `/graphql` over HTTP. It receives subscriptions through SSE (`app/entry-client.tsx`). This browser application does not import the Alvyn library.

![Example Client Components](embed:example-client-components)

## Website Server

The Next.js server renders the landing page and documentation pages (`website/src/app/`). The Documentation Source loads content from the website's MDX collection (`website/src/lib/source.ts`). The Search API builds search data from that source (`website/src/app/api/search/route.ts`).

![Website Server Components](embed:website-server-components)

## Website Client

The Journey Simulator runs a local, interactive example in the browser (`website/src/components/JourneySimulator.tsx`). The Search Dialog requests results from `/api/search` (`website/src/components/search.tsx`). The simulator does not write events to PostgreSQL.

![Website Client Components](embed:website-client-components)
