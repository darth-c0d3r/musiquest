
import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 * Servlet implementation class Homepage
 */
@WebServlet("/Homepage")
public class Homepage extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Homepage() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
    @SuppressWarnings("unchecked")
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		
		if(session.getAttribute("user_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in").toString());
			return;
		}
		
		int user_id = (Integer) session.getAttribute("user_id");
		
		String query1 = "select song_id, name from song order by num_views desc limit 10;";
		String query2 = "select song_id, name from song order by num_likes desc limit 10;";
		String query3 = "select song_id, name from song order by release_date desc limit 10;";

		String query4 = "select album.album_id, album.name, sum(song.num_views) + album.num_views "
				+ "as total_views from album join song on album.album_id = song.album_id group by "
				+ "album.album_id, album.name order by total_views desc limit 10;";
		String query5 = "select album_id, name from album order by num_likes desc limit 10;";

		String query6 = "select artist.artist_id, artist.name, sum(song.num_views) + artist.num_views "
				+ "as total_views from artist join song on artist.artist_id = song.artist_id group by "
				+ "artist.artist_id, artist.name order by total_views desc limit 10;";
		String query7 = "select artist_id, name from artist order by num_likes desc limit 10;";
		
		String query8 = " select song.song_id, song.name from user_song join song on song.song_id = user_song.song_id"
				+ " where user_id = ? order by last_viewed desc limit 10;";
		
		String res1 = DbHelper.executeQueryJson(query1, 
				new DbHelper.ParamType[] {}, new String[] {});
		
		String res2 = DbHelper.executeQueryJson(query2, 
				new DbHelper.ParamType[] {}, new String[] {});
		
		String res3 = DbHelper.executeQueryJson(query3, 
				new DbHelper.ParamType[] {}, new String[] {});

		String res4 = DbHelper.executeQueryJson(query4, 
				new DbHelper.ParamType[] {}, new String[] {});

		String res5 = DbHelper.executeQueryJson(query5, 
				new DbHelper.ParamType[] {}, new String[] {});

		String res6 = DbHelper.executeQueryJson(query6, 
				new DbHelper.ParamType[] {}, new String[] {});

		String res7 = DbHelper.executeQueryJson(query7, 
				new DbHelper.ParamType[] {}, new String[] {});
		
		String res8 = DbHelper.executeQueryJson(query8, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Object[] {user_id});
		
		JSONParser parser = new JSONParser();
		JSONObject json1 = new JSONObject();
		JSONObject json2 = new JSONObject();
		JSONObject json3 = new JSONObject();
		JSONObject json4 = new JSONObject();
		JSONObject json5 = new JSONObject();
		JSONObject json6 = new JSONObject();
		JSONObject json7 = new JSONObject();
		JSONObject json8 = new JSONObject();
		

		try {
			json1 = (JSONObject) parser.parse(res1);
			json2 = (JSONObject) parser.parse(res2);
			json3 = (JSONObject) parser.parse(res3);
			json4 = (JSONObject) parser.parse(res4);
			json5 = (JSONObject) parser.parse(res5);
			json6 = (JSONObject) parser.parse(res6);
			json7 = (JSONObject) parser.parse(res7);
			json8 = (JSONObject) parser.parse(res8);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		JSONObject ret = new JSONObject();
		ret.put("song_views", json1);
		ret.put("song_likes", json2);
		ret.put("song_date" , json3);
		ret.put("album_views" , json4);
		ret.put("album_likes" , json5);
		ret.put("artist_views" , json6);
		ret.put("artist_likes" , json7);
		ret.put("recently_played", json8);

//try {
//	Thread.sleep(500);
//} catch (InterruptedException e) {
//	e.printStackTrace();
//}
		response.getWriter().print(ret.toString());
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}


}
