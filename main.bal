import ballerina/http;
import ballerina/io;
import ballerina/os;

final int PORT = check int:fromString(os:getEnv("DB_PORT"));
listener http:Listener api = new (PORT);

service / on api {
    final DB db;
    function init() returns error? {
        self.db = check new ();
        io:println(`listening on port: ${PORT}`);
    }

    resource function post posts(Post post) returns http:InternalServerError? {
        do {
            check self.db.createPost(post);
            return ();
        } on fail var e {
            io:println(e.message());
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get posts() returns PostWithId[]|http:InternalServerError {
        do {
            PostWithId[] posts = check self.db.getPosts();
            return posts;
        } on fail var e {
            io:println(e.message());
            return http:INTERNAL_SERVER_ERROR;
        }
    }
}
