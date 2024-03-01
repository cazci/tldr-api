import ballerina/os;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

class DB {
    final postgresql:Client dbClient;

    function init() returns error? {
        PostgreOpts opts = {
            host: os:getEnv("DB_HOST"),
            username: os:getEnv("DB_USERNAME"),
            password: os:getEnv("DB_PASSWORD"),
            db: os:getEnv("DB_DATABASE"),
            port: check int:fromString(os:getEnv("DB_PORT"))
        };
        self.dbClient = check new (opts.host, opts.username, opts.password, opts.db, opts.port);
    }

    function getClient() returns postgresql:Client {
        return self.dbClient;
    }

    function closeClient() returns error? {
        check self.dbClient.close();
    }

    function safeMigrate() returns error? {
        sql:ParameterizedQuery q = `CREATE TABLE post (
            id SERIAL PRIMARY KEY,
            title TEXT
        );`;
        _ = check self.dbClient->execute(q);
    }

    function createPost(Post post) returns error? {
        sql:ParameterizedQuery q = `INSERT INTO post (
            title
        ) VALUES (
            ${post.title}
        );`;
        _ = check self.dbClient->execute(q);
    }

    function getPosts() returns PostWithId[]|error {
        sql:ParameterizedQuery q = `SELECT * FROM post;`;
        stream<record {}, sql:Error?> resultStream = self.dbClient->query(q);
        return from record {} post in resultStream
            let PostWithId _post = {
                id: <int>post["id"],
                title: <string>post["title"]
            }
            select _post;
    }
}
