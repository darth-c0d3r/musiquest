
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
 * Servlet implementation class AlbumInfo
 */
@WebServlet("/AlbumInfo")
public class AlbumInfo extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AlbumInfo() {
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
		
		if(request.getParameter("album_id") == null) {
			response.getWriter().print("Incorrect Parameters Provided");
			return;
		}
		
		int album_id = Integer.parseInt(request.getParameter("album_id"));
		int user_id = (Integer) session.getAttribute("user_id");
		JSONParser parser = new JSONParser();
		
		String query1 = "update user_album set num_views = num_views+1 where album_id = ? and user_id = ?";
		String res1 = DbHelper.executeUpdateJson(query1, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT},
				new Object[] {album_id, user_id});
		JSONObject json1 = new JSONObject();
		try {
			json1 = (JSONObject) parser.parse(res1);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		if(json1.get("status").equals(false)) {
			String query2 = "insert into user_album(album_id,user_id) values (?, ?)";
			DbHelper.executeUpdateJson(query2, 
					new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT},
					new Object[] {album_id, user_id});
			
			query2 = "update album set num_views = num_views + 1 where album_id = ?";
			DbHelper.executeUpdateJson(query2, 
					new DbHelper.ParamType[] {DbHelper.ParamType.INT},
					new Object[] {album_id});
			
		}
		
		String query3 = "with album_entry as (select * from album where album_id = ?) "
				+ "select album_entry.*, user_album.relation_type, artist.name as artist_name "
				+ "from album_entry, user_album, artist where user_id = ? and album_entry.album_id = user_album.album_id "
				+ "and album_entry.artist_id = artist.artist_id";
		String res3 = DbHelper.executeQueryJson(query3, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT}, 
				new Object[] {album_id, user_id});
		
		String query4 = "select song.song_id, song.name from song where album_id = ?";
		String res4 = DbHelper.executeQueryJson(query4, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Object[] {album_id});
		
		JSONObject json3 = new JSONObject();
		JSONObject json4 = new JSONObject();
		
		try {
			json3 = (JSONObject) parser.parse(res3);
			json4 = (JSONObject) parser.parse(res4);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		JSONObject ret = new JSONObject();
		ret.put("metadata", json3);
		ret.put("songs", json4);
		
		response.getWriter().print(ret.toString());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}
