var convert = function()
{
    var string = "";
    var movies = getAllMovies();



    string = ""
    string = string + ("<html>")
    string = string + ("<head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"></head>")
    string = string + ("<body>")
    string = string + ("<table border=\"1\">")
    string = string + ("<tr>")
    string = string + ("<th>Title</th>")
    string = string + ("<th>Rating</th>")
    string = string + ("<th>Language</th>")
    string = string + ("<th>IMDB-#</th>")
    string = string + ("<th>IMDB-Title</th>")
    string = string + ("<th>IMDB-Year</th>")
    string = string + ("<th>IMDB-Director</th>")
    string = string + ("<th>IMDB-Writer</th>")
    string = string + ("<th>IMDB-Genre</th>")
    string = string + ("</tr>")


    for (var i = 0; i < movies.length; i++)
    {
        string = string + ("<tr>")
        string = string + ("<td>" + movies[i]["title"] + "</td>")
        string = string + ("<td>" + movies[i]["rating"] + "</td>")
        string = string + ("<td>" + movies[i]["language"] + "</td>")
        string = string + ("<td>" + movies[i]["imdb_id"] + "</td>")
        string = string + ("<td>" + movies[i]["imdb_title"] + "</td>")
        string = string + ("<td>" + movies[i]["imdb_year"] + "</td>")
        string = string + ("<td>" + movies[i]["imdb_director"] + "</td>")
        string = string + ("<td>" + movies[i]["imdb_writer"] + "</td>")
        string = string + ("<td>" + movies[i]["imdb_genre"] + "</td>")
        string = string + ("</tr>")
    }


    string = string + ("</table>")
    string = string + ("</body>")
    string = string + ("</html>")

    
    return string;
    
}