workspace {
    !docs docs

    model {
        user = person "User" "Integrates Alvyn or uses the repository's example and documentation."
        postgres = softwareSystem "PostgreSQL" "Hosts the Alvyn event-store schema and executes its queries."

        alvyn = softwareSystem "Alvyn" "Provides TypeScript event history on PostgreSQL and repository-owned examples and documentation." {
            library = container "Alvyn Library" "Runs inside a client's Node.js process to persist and replay events." "TypeScript, Node.js" {
                eventStore = component "EventStore" "Exposes setup, append, reads, transactions, subscriptions, and maintenance operations." "TypeScript"
                schema = component "Schema" "Migrates or verifies the versioned PostgreSQL schema." "TypeScript, SQL"
                stream = component "Stream" "Appends, reads, and pages events with version and idempotency checks." "TypeScript, SQL"
                aggregate = component "Aggregate" "Builds typed aggregate handles and replays events through client reducers." "TypeScript"
                snapshot = component "Snapshot" "Builds snapshot handles and stores derived snapshot events in their source streams." "TypeScript"
                subscription = component "Subscription" "Reads committed event history and waits for new events with LISTEN/NOTIFY or polling." "TypeScript, SQL"
                projection = component "Projection" "Runs client handlers from event history and stores checkpoints." "TypeScript, SQL"
                outbox = component "Outbox" "Claims and marks outbox entries for client-supplied handlers." "TypeScript, SQL"
                crypto = component "Crypto" "Encrypts event fields and manages per-entity keys." "TypeScript, Node.js crypto"
                upcaster = component "Upcaster" "Transforms old event payloads during reads." "TypeScript"
            }

            exampleServer = container "Example Alvyn Full Stack App Server" "Serves bank-account GraphQL operations and subscriptions." "TypeScript, Elysia, GraphQL Yoga, Node.js" {
                exampleGraphql = component "GraphQL API" "Handles bank-account queries, mutations, and subscriptions." "TypeScript, GraphQL Yoga"
                exampleBankAccount = component "Bank Account Aggregate" "Defines account state and its event reducers." "TypeScript"
                exampleTransaction = component "Transaction Aggregate and Balance Snapshot" "Defines transaction events and the derived account balance." "TypeScript"
            }

            exampleClient = container "Example Alvyn Full Stack App Client" "Runs the bank-account demo in the browser." "TypeScript, React, Apollo Client" {
                exampleUi = component "Account Components" "Collects account commands and displays account data." "React"
                exampleApollo = component "GraphQL Client" "Sends queries and mutations over HTTP and subscriptions over SSE." "Apollo Client, graphql-sse"
            }

            websiteServer = container "Website Server" "Serves the product site, documentation, and search data." "TypeScript, Next.js" {
                websitePages = component "Home and Docs Pages" "Renders the landing page and MDX documentation pages." "Next.js, Fumadocs"
                websiteSource = component "Documentation Source" "Loads documentation content for routes and search." "Fumadocs"
                websiteSearch = component "Search API" "Serves a static search index from documentation content." "Next.js, Fumadocs"
            }

            websiteClient = container "Website Client" "Runs interactive product-site features in the browser." "TypeScript, React" {
                websiteJourney = component "Journey Simulator" "Shows a local interactive event-history example." "React"
                websiteSearchUi = component "Search Dialog" "Requests and displays documentation search results." "React, Fumadocs"
            }
        }

        user -> aggregate "Defines typed domain models with"
        user -> exampleUi "Uses the bank-account demo through"
        user -> websiteJourney "Explores event history through"
        user -> websiteSearchUi "Searches documentation through"

        exampleUi -> exampleApollo "Submits account operations through"
        exampleApollo -> exampleGraphql "Sends GraphQL requests and SSE subscriptions to"
        exampleGraphql -> exampleBankAccount "Loads and appends accounts with"
        exampleGraphql -> exampleTransaction "Loads transactions and balances with"
        exampleGraphql -> eventStore "Initializes and reads from"
        exampleBankAccount -> aggregate "Defines its model with"
        exampleTransaction -> aggregate "Defines its transaction model with"
        exampleTransaction -> snapshot "Defines its balance with"

        eventStore -> schema "Migrates or verifies with"
        eventStore -> stream "Appends and reads through"
        eventStore -> subscription "Starts event streams through"
        eventStore -> projection "Runs read models through"
        eventStore -> outbox "Processes entries through"
        eventStore -> crypto "Manages keys through"
        eventStore -> upcaster "Registers event transformations with"
        aggregate -> eventStore "Loads and appends through"
        snapshot -> eventStore "Loads and appends snapshot events through"
        stream -> crypto "Encrypts and decrypts fields with"
        stream -> upcaster "Transforms event payloads with"
        subscription -> upcaster "Transforms subscribed events with"
        projection -> upcaster "Transforms projected events with"

        schema -> postgres "Creates and verifies tables in"
        stream -> postgres "Writes and reads events in"
        subscription -> postgres "Reads events and listens for notifications from"
        projection -> postgres "Reads events and stores checkpoints in"
        outbox -> postgres "Claims and marks entries in"
        crypto -> postgres "Stores and revokes keys in"

        websitePages -> websiteJourney "Serves interactive landing content to"
        websiteSearchUi -> websiteSearch "Requests search data from"
        websitePages -> websiteSource "Loads documentation through"
        websiteSearch -> websiteSource "Builds its index from"
    }

    views {
        systemContext alvyn "alvyn-context" {
            include *
            autoLayout lr
        }

        container alvyn "alvyn-containers" {
            include *
            autoLayout lr
        }

        component library "alvyn-library-components" {
            include *
            autoLayout lr
        }

        component exampleServer "example-server-components" {
            include *
            autoLayout lr
        }

        component exampleClient "example-client-components" {
            include *
            autoLayout lr
        }

        component websiteServer "website-server-components" {
            include *
            autoLayout lr
        }

        component websiteClient "website-client-components" {
            include *
            autoLayout lr
        }
    }
}
