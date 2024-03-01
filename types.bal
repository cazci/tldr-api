type PostgreOpts record {|
    string host;
    string username;
    string password;
    string db;
    int port;
|};

type Post readonly & record {|
    string title;
|};

type PostWithId readonly & record {|
    int id;
    string title;
|};
