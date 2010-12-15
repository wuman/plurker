using Soup;
using Roguso;
using Posix;

public class Plurker.App : Object {

    public static const string PLURKER_API_KEY = "eRT4YZjztBaQPylrq85yqBABAv0zhIqN";

    public PlurkClient client;
    private string username;
    private string password;

    public App(string username, string pwd, string api_key) {
        client = new PlurkClient(api_key);
        this.username = username;
        this.password = pwd;
    }

    public void profile(string? user_id) {
        client.profile_received.connect((client, e, profile) => {
            die_on_error(e);

            if ( profile != null && profile.user != null ) {
                GLib.stdout.printf("[%s] %s: %d friends and %d fans.\n",
                    profile.user.user_id,
                    ( profile.user.display_name != null ) ? profile.user.display_name : ( profile.user.nick_name != null ? profile.user.nick_name : "" ),
                    profile.friends_count.to_string().to_int(),
                    profile.fans_count.to_string().to_int()
                );
            }

            client.logout();
        });

        if ( user_id == null ) {
            client.login(username, password, false);
        } else {
            client.login(username, password, true);
            client.get_public_profile(user_id);
        }
    }

    public void karma() {
        client.karma_received.connect((client, e, karma) => {
            die_on_error(e);

            GLib.stdout.printf("Current karma is %.1f.\n", karma);

            client.logout();
        });

        client.login(username, password, true);
        client.get_karma();
    }

    public void cliques() {
        client.cliques_received.connect((client, e, cliques) => {
            die_on_error(e);

            for ( int i = 0; i < cliques.length; i++ ) {
                GLib.stdout.printf("%2d: %s\n", i+1, cliques[i]);
            }

            client.logout();
        });

        client.login(username, password, true);
        client.get_cliques();
    }

    public void cliqueusers(string clique_name) {
        client.clique_users_received.connect((client, e, clique_name, users) => {
            die_on_error(e);

            uint length = users.get_count();
            for ( int i = 0; i < length; i++ ) {
                User user = users.get_pos(i);
                GLib.stdout.printf("%2d: %s", i+1, print_from_user(user));
            }

            client.logout();
        });

        client.login(username, password, true);
        client.get_clique_users(clique_name);
    }

    public void createclique(string clique_name) {
        client.clique_created.connect((client, e, clique_name) => {
            die_on_error(e);

            GLib.stdout.printf("Clique %s created.\n", clique_name);

            client.logout();
        });

        client.login(username, password, true);
        client.create_clique(clique_name);
    }

    public void renameclique(string clique_name, string new_name) {
        client.clique_renamed.connect((client, e, clique_name, new_name) => {
            die_on_error(e);

            GLib.stdout.printf("Clique %s is renamed to %s.\n", clique_name, new_name);

            client.logout();
        });

        client.login(username, password, true);
        client.rename_clique(clique_name, new_name);
    }

    public void addtoclique(string clique_name, string user_id) {
        client.user_added_to_clique.connect((client, e, clique_name, user_id) => {
            die_on_error(e);

            GLib.stdout.printf("User %s is added to clique %s.\n", user_id, clique_name);

            client.logout();
        });

        client.login(username, password, true);
        client.add_user_to_clique(clique_name, user_id);
    }

    public void removefromclique(string clique_name, string user_id) {
        client.user_removed_from_clique.connect((client, e, clique_name, user_id) => {
            die_on_error(e);

            GLib.stdout.printf("User %s is removed from clique %s.\n", user_id, clique_name);

            client.logout();
        });

        client.login(username, password, true);
        client.remove_user_from_clique(clique_name, user_id);
    }

    public void addplurk(string content) {
        client.plurk_received.connect((client, e, plurk) => {
            die_on_error(e);

            if ( plurk != null ) {
                GLib.stdout.printf("The following plurk has been added:\n%s", print_from_plurk(plurk));
            }

            client.logout();
        });

        client.login(username, password, true);
        client.add_plurk(content, Plurk.Qualifier.DEFAULT, null);
    }

    public void editplurk(string plurk_id, string content) {
        client.plurk_received.connect((client, e, plurk) => {
            die_on_error(e);

            if ( plurk != null ) {
                GLib.stdout.printf("The plurk has been updated:\n%s", print_from_plurk(plurk));
            }

            client.logout();
        });

        client.login(username, password, true);
        client.edit_plurk(plurk_id, content);
    }

    public void deleteplurk(string plurk_id) {
        client.plurk_deleted.connect((client, e, plurk_id) => {
            die_on_error(e);

            GLib.stdout.printf("The plurk %s has been deleted.\n", plurk_id);

            client.logout();
        });

        client.login(username, password, true);
        client.delete_plurk(plurk_id);
    }

    public void deleteresponse(string plurk_id, string response_id) {
        client.response_deleted.connect((client, e, plurk_id, response_id) => {
            die_on_error(e);

            GLib.stdout.printf("The response %s (belonging to plurk %s) has been deleted.\n", response_id, plurk_id);

            client.logout();
        });

        client.login(username, password, true);
        client.delete_response(plurk_id, response_id);
    }

    public void addresponse(string plurk_id, string content) {
        client.response_received.connect((client, e, response) => {
            die_on_error(e);

            if ( response != null ) {
                GLib.stdout.printf("The following response has been added:\n%s", print_from_response(response));
            }

            client.logout();
        });

        client.login(username, password, true);
        client.add_response(plurk_id, content);
    }

    public void mute(string[] ids) {
        client.plurks_muted.connect((client, e, ids) => {
            die_on_error(e);

            if ( ids != null ) {
                for ( int i = 0; i < ids.length; i++ ) {
                    GLib.stdout.printf("%2d: plurk %s is muted.\n", i+1, ids[i]);
                }
            }

            client.logout();
        });

        client.login(username, password, true);
        client.mute_plurks(ids);
    }

    public void unmute(string[] ids) {
        client.plurks_unmuted.connect((client, e, ids) => {
            die_on_error(e);

            if ( ids != null ) {
                for ( int i = 0; i < ids.length; i++ ) {
                    GLib.stdout.printf("%2d: plurk %s is unmuted.\n", i+1, ids[i]);
                }
            }

            client.logout();
        });

        client.login(username, password, true);
        client.unmute_plurks(ids);
    }

    public void favorite(string[] ids) {
        client.plurks_favorited.connect((client, e, ids) => {
            die_on_error(e);

            if ( ids != null ) {
                for ( int i = 0; i < ids.length; i++ ) {
                    GLib.stdout.printf("%2d: plurk %s is favorited.\n", i+1, ids[i]);
                }
            }

            client.logout();
        });

        client.login(username, password, true);
        client.favorite_plurks(ids);
    }

    public void unfavorite(string[] ids) {
        client.plurks_unfavorited.connect((client, e, ids) => {
            die_on_error(e);

            if ( ids != null ) {
                for ( int i = 0; i < ids.length; i++ ) {
                    GLib.stdout.printf("%2d: plurk %s is unfavorited.\n", i+1, ids[i]);
                }
            }

            client.logout();
        });

        client.login(username, password, true);
        client.unfavorite_plurks(ids);
    }

    public void plurks(int limit = 0, PlurkApi.PlurkFilterType filter = PlurkApi.PlurkFilterType.ALL) {
        int plurk_count = 0;

        client.plurk_received.connect((client, e, plurk) => {
            die_on_error(e);

            GLib.stdout.printf("%2d: %s", ++plurk_count, print_from_plurk(plurk));
        });

        client.timeline_complete.connect((client, e, timeline) => {
            die_on_error(e);

            if ( timeline.get_count() <= 0 ) {
                GLib.stdout.printf("The timeline is empty.\n");
            }

            client.logout();
        });

        client.login(username, password, true);
        client.get_timeline(null, limit, filter);
    }

    public void unread(int limit = 0) {
        int plurk_count = 0;

        client.plurk_received.connect((client, e, plurk) => {
            die_on_error(e);

            GLib.stdout.printf("%2d: %s", ++plurk_count, print_from_plurk(plurk));
        });

        client.timeline_complete.connect((client, e, timeline) => {
            die_on_error(e);

            if ( timeline.get_count() <= 0 ) {
                GLib.stdout.printf("No unread plurks.\n");
            }

            client.logout();
        });

        client.login(username, password, true);
        client.get_unread_timeline(null, limit);
    }

    public void responses(string plurk_id) {
        int response_count = 0;

        client.response_received.connect((client, e, response) => {
            die_on_error(e);

            GLib.stdout.printf("%2d: %s", ++response_count, print_from_response(response));
        });

        client.responses_complete.connect((client, e, plurk_id, from_response, responses) => {
            die_on_error(e);

            uint length = responses.get_count();
            if ( from_response + length < responses.response_count ) {
                client.get_responses(plurk_id, from_response + length.to_string().to_int());
            } else {
                if ( responses.response_count <= 0 ) {
                    GLib.stdout.printf("This plurk has no responses.\n");
                }

                client.logout();
            }
        });

        client.login(username, password, true);
        client.get_responses(plurk_id);
    }

    private static string print_from_plurk(Plurk plurk) {
        return "[%10s] (%3d) %8s%-20s %s\n".printf(
                plurk.plurk_id, 
                plurk.response_count.to_string().to_int(),
                plurk.owner_id,
                plurk.owner != null ? " (%s)".printf(plurk.owner.nick_name) : "", 
                plurk.content_raw);
    }

    private static string print_from_response(Response response) {
        return "[%10s][%10s] %8s%-20s %s\n".printf(
                response.plurk_id, 
                response.response_id,
                response.user_id,
                response.owner != null ? " (%s)".printf(response.owner.nick_name) : "",
                response.content_raw);
    }

    private static string print_from_user(User user) {
        return "[%8s] %5.1f %-12s %-20s %-20s\n".printf(
            user.user_id,
            user.karma,
            user.nick_name == null ? "" : user.nick_name,
            user.display_name == null ? "" : user.display_name,
            user.full_name == null ? "" : user.full_name);
    }

}

private void die_on_error(Error e) {
    if ( e != null ) {
        GLib.error("%d: %s", e.code, e.message);
    }
}


private const string _chars = "0123456789abcdefghijklmnopqrstuvwxyz";

private string base10toN(string n, int b) {
    int num = n.to_int();

    if ( num < 0 || b < 2 || b > 36 ) {
        return "";
    }

    var s = "";
    while ( true ) {
        var r = num % b;
        s = _chars[r].to_string() + s;
        num = num / b;
        if ( num == 0 ) {
            break;
        }
    }
    return s;
}

private string base10to36(string n) {
    return base10toN(n, 36);
}

public int main(string[] args) {

    File file = File.new_for_path("plurker.config");
    if ( !file.query_exists() ) {
        GLib.stderr.printf("File '%s' doesn't exist.\n", file.get_path());
        return 1;
    }

    string username = null;
    string api_key = null;
    string password = null;
    try {
        var dis = new DataInputStream(file.read());
        string line;
        while ( ( line = dis.read_line(null) ) != null ) {
            string[] vals = line.split(" ", 2);
            if ( vals.length == 2 ) {
                switch ( vals[0] ) {
                case "username":
                    username = vals[1];
                    break;
                case "apikey":
                    api_key = vals[1];
                    break;
                case "password":
                    password = vals[1];
                    break;
                default:
                    break;
                }
            }
        }
    } catch ( Error e ) {
        die_on_error(e);
    }

    if ( api_key == null || api_key == "" ) {
        api_key = Plurker.App.PLURKER_API_KEY;
    }

    if ( username == null || username == "" ) {
        GLib.stderr.printf("Username is not set in plurker.config!\n");
        return 1;
    }

    if ( args.length < 2 ) {
        GLib.stdout.printf("""
Specify the command to execute.

plurks [limit [filter]]                     : show at most [limit] plurks filtered by [filter].
unread [limit]                              : show at most [limit] unread plurks.
responses <plurk_id>                        : show responses for plurk with <plurk_id>.
mute <plurk_id> [<plurk_id> ...]            : mute listed plurks
unmute <plurk_id> [<plurk_id> ...]          : unmute listed plurks
favorite <plurk_id> [<plurk_id> ...]        : favorite listed plurks
unfavorite <plurk_id> [<plurk_id> ...]      : unfavorite listed plurks
addplurk <content>                          : post a plurk
editplurk <plurk_id> <content>              : edit a plurk with new content
deleteplurk <plurk_id>                      : delete a plurk
addresponse <plurk_id> <content>            : post a response for plurk with <plurk_id>
deleteresponse <plurk_id> <response_id>     : delete a response belong to a plurk
karma                                       : show the current karma value
profile [user_id]                           : show the [user_id]'s profile, or the logged in user's own profile if user_id is not specified.
cliques                                     : show a list of the user's current cliques
cliqueusers <clique_name>                   : show the users in the clique
createclique <clique_name>                  : create a clique
addtoclique <clique_name> <user_id>         : add user with <user_id> to clique named <clique_name>
removefromclique <clique_name> <user_id>    : remove user with <user_id> from clique named <clique_name>


""");
        return 1;
    }

    string cmd = args[1];

    MainLoop loop = new MainLoop(null, true);

    Plurker.App app;

    if ( password == null || password == "" ) {
        unowned string pwd = Posix.getpass("Enter your password: ");
        app = new Plurker.App(username, pwd, api_key);
    } else {
        app = new Plurker.App(username, password, api_key);
    }

    app.client.authenticate.connect((client, e, is_logged_in) => {
        die_on_error(e);

        if ( !is_logged_in ) {
            loop.quit();
        }
    });

    switch ( cmd ) {
    case "profile":
        if ( args.length >= 3 ) {
            app.profile(args[2]);
        } else {
            app.profile(null);
        }
        break;
    case "karma":
        app.karma();
        break;
    case "plurks":
        int limit = 0;
        PlurkApi.PlurkFilterType filter = PlurkApi.PlurkFilterType.ALL;
        if ( args.length >= 3 ) {
            limit = args[2].to_int();
        }
        if ( args.length >= 4 ) {
            filter = PlurkApi.PlurkFilterType.from_string(args[3]);
        }
        app.plurks(limit, filter);
        break;
    case "unread":
        int limit = 0;
        if ( args.length >= 3 ) {
            limit = args[2].to_int();
        }
        app.unread(limit);
        break;
    case "responses":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify plurk id!\n");
            return 1;
        }
        string plurk_id = args[2];
        app.responses(plurk_id);
        break;
    case "mute":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify at least a plurk id!\n");
            return 1;
        }
        app.mute(args[2:args.length]);
        break;
    case "unmute":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify at least a plurk id!\n");
            return 1;
        }
        app.unmute(args[2:args.length]);
        break;
    case "favorite":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify at least a plurk id!\n");
            return 1;
        }
        app.favorite(args[2:args.length]);
        break;
    case "unfavorite":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify at least a plurk id!\n");
            return 1;
        }
        app.unfavorite(args[2:args.length]);
        break;
    case "addplurk":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify the content to post!\n");
            return 1;
        }
        string content;
        if ( args.length == 3 ) {
            content = args[2];
        } else {
            content = string.joinv(" ", args[2:args.length]);
        }
        app.addplurk(content);
        break;
    case "editplurk":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify the plurk id for which you want to edit!\n");
            return 1;
        }
        if ( args.length < 4 ) {
            GLib.stdout.printf("Specify the content to update!\n");
            return 1;
        }
        string content;
        if ( args.length == 4 ) {
            content = args[3];
        } else {
            content = string.joinv(" ", args[3:args.length]);
        }
        app.editplurk(args[2], content);
        break;
    case "addresponse":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify the plurk id for which you want to add the response to!\n");
            return 1;
        }
        if ( args.length < 4 ) {
            GLib.stdout.printf("Specify the content to post!\n");
            return 1;
        }
        string content;
        if ( args.length == 4 ) {
            content = args[3];
        } else {
            content = string.joinv(" ", args[3:args.length]);
        }
        app.addresponse(args[2], content);
        break;
    case "deleteplurk":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify the plurk id for which you want to delete!\n");
            return 1;
        }
        app.deleteplurk(args[2]);
        break;
    case "deleteresponse":
        if ( args.length < 4 ) {
            GLib.stdout.printf("Specify the response id (and plurk it belongs to) for which you want to delete!\n");
            return 1;
        }
        app.deleteresponse(args[2], args[3]);
        break;
    case "cliques":
        app.cliques();
        break;
    case "cliqueusers":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify the clique name for which you want to list the users!\n");
            return 1;
        }
        string content;
        if ( args.length == 3 ) {
            content = args[2];
        } else {
            content = string.joinv(" ", args[2:args.length]);
        }
        app.cliqueusers(content);
        break;
    case "createclique":
        if ( args.length < 3 ) {
            GLib.stdout.printf("Specify the clique name for which you want to create!\n");
            return 1;
        }
        app.createclique(args[2]);
        break;
    case "renameclique":
        if ( args.length < 4 ) {
            GLib.stdout.printf("Specify the clique you want to rename and its new name!\n");
            return 1;
        }
        app.renameclique(args[2], args[3]);
        break;
    case "addtoclique":
        if ( args.length < 4 ) {
            GLib.stdout.printf("Specify the user id and the clique name!\n");
            return 1;
        }
        app.addtoclique(args[2], args[3]);
        break;
    case "removefromclique":
        if ( args.length < 4 ) {
            GLib.stdout.printf("Specify the user id and the clique name!\n");
            return 1;
        }
        app.removefromclique(args[2], args[3]);
        break;
    default:
        GLib.stdout.printf("Command not supported!\n");
        return 1;
    }

    loop.run();

    return 0;
}

