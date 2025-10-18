module 0x0::journal {
    use std::string;
    use std::vector;
    use sui::object;
    use sui::tx_context;
    use sui::clock;

    public struct Entry has store {
        content: string::String,
        created_at_ms: u64,
    }

    public struct Journal has key, store {
        id: object::UID,
        owner: address,
        title: string::String,
        entries: vector<Entry>,
    }

    public fun new_journal(title: string::String, ctx: &mut tx_context::TxContext) {
        let id = object::new(ctx);
        let owner = tx_context::sender(ctx);
        let journal = Journal {
            id,
            owner,
            title,
            entries: vector::empty<Entry>(),
        };
        transfer::transfer(journal, owner);
    }

    public fun add_entry(journal: &mut Journal, content: string::String, clock: &clock::Clock, ctx: &tx_context::TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(sender == journal.owner, 0);
        let now_ms = clock::timestamp_ms(clock);
        let entry = Entry {
            content,
            created_at_ms: now_ms,
        };
        vector::push_back(&mut journal.entries, entry);
    }
}
