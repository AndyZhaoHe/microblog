import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

actor {
    public type Message = {
        author: Text;
        text: Text;
        time: Time.Time;
    };
    public type Follow_info = {
        name: ?Text;
        pid: Text;
    };
    
    public type Microblog = actor {
        follow: shared (Principal) -> async ();
        follows: shared query () -> async [Principal];
        remove_all : shared() -> async ();
        post: shared (Text) -> async ();
        posts: shared query (Time.Time) -> async [Message];
        timeline: shared (Time.Time) -> async [Message];
        set_name: shared (Text) -> async ();
        get_name: shared query () -> async ?Text;
        get_follow_infos: shared () -> async [Follow_info];
        update_follow_infos: shared () -> async ();
        get_someone_posts: shared (Text) -> async [Message];
    };

    stable var followed: List.List<Principal> = List.nil();
    stable var messages: List.List<Message> = List.nil();
    stable var follow_infos: List.List<Follow_info> = List.nil();
    stable var name: Text = "nil";

   public shared func remove_all() : async () {
      followed := List.nil();
   };

    public shared func follow(id: Principal): async () {
        followed := List.push(id, followed);
        await update_follow_infos();
    };

    public shared query func follows(): async [Principal] {
        List.toArray(followed);
    };

    public shared func post(text: Text): async () {
        let msg = { author = name; text = text; time = Time.now() };
        messages := List.push(msg, messages);
    };

    public shared query func posts(since: Time.Time): async [Message] {
        var msgs: List.List<Message> = List.nil();
        for (msg in Iter.fromList(messages)) {
            if (msg.time > since) {
                msgs := List.push(msg, msgs);
            };
        };
        List.toArray(msgs)
    };

    public shared func timeline(since: Time.Time): async [Message] {
        var all: List.List<Message> = List.nil();

        for (id in Iter.fromList(followed)) {
            let canister: Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg, all);
            };
        };
        List.toArray(all);
    };

    public shared(msg) func set_name(_name: Text): async () {
        name := _name;
    };

    public shared query func get_name(): async Text {
        name;
    };

    public shared func get_follow_infos(): async [Follow_info] {
        List.toArray(follow_infos);
    };

    public shared func update_follow_infos(): async () {
        follow_infos := List.nil();
        for (id in Iter.fromList(followed)) {
            let canister : Microblog = actor(Principal.toText(id));
            let _name = await canister.get_name();
            let info : Follow_info = { name = _name; pid = Principal.toText(id) };
            follow_infos := List.push(info, follow_infos);
        };
    };

    public shared func get_someone_posts(pid: Text): async [Message] {
        let canister: Microblog = actor(pid);
        let msgs = await canister.posts(0);
        msgs;
    }
}