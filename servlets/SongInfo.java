
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
 * Servlet implementation class SongInfo
 */
@WebServlet("/SongInfo")
public class SongInfo extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public SongInfo() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		
		if(session.getAttribute("user_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in").toString());
			return;
		}
		
		if(request.getParameter("song_id") == null) {
			response.getWriter().print("Incorrect Parameters Provided");
			return;
		}
				
		int song_id = Integer.parseInt(request.getParameter("song_id"));
		int user_id = (Integer) session.getAttribute("user_id");
		JSONParser parser = new JSONParser();
		
		String query1 = "update user_song set num_views = num_views+1, "
				+ "last_viewed = current_timestamp where song_id = ? and user_id = ?";
		String res1 = DbHelper.executeUpdateJson(query1, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT},
				new Object[] {song_id, user_id});
		JSONObject json1 = new JSONObject();
		try {
			json1 = (JSONObject) parser.parse(res1);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		if(json1.get("status").equals(false)) {
			String query2 = "insert into user_song(song_id,user_id) values (?, ?)";
			DbHelper.executeUpdateJson(query2, 
					new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT},
					new Object[] {song_id, user_id});
			
			query2 = "update song set num_views = num_views + 1 where song_id = ?";
			DbHelper.executeUpdateJson(query2, 
					new DbHelper.ParamType[] {DbHelper.ParamType.INT},
					new Object[] {song_id});
			
		}
		
		String query3 = "with song_entry as (select * from song where song_id = ?) "
				+ "select song_entry.*, user_song.relation_type, album.name as album_name, artist.name as artist_name "
				+ "from song_entry, user_song, artist, album where user_id = ? and song_entry.song_id = user_song.song_id "
				+ "and song_entry.album_id = album.album_id and song_entry.artist_id = artist.artist_id";

		String res3 = DbHelper.executeQueryJson(query3, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT},
				new Object[] {song_id, user_id});
		JSONObject json3 = new JSONObject();
		
		
		try {
			json3 = (JSONObject) parser.parse(res3);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		response.getWriter().print(json3.toString());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}


}
