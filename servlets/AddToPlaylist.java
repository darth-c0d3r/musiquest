

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
 * Servlet implementation class AddToPlaylist
 */
@WebServlet("/AddToPlaylist")
public class AddToPlaylist extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddToPlaylist() {
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
		
		if(request.getParameter("song_id") == null || request.getParameter("playlist_id") == null) {
			response.getWriter().print("Incorrect Parameters Provided");
			return;
		}
				
		int song_id = Integer.parseInt(request.getParameter("song_id"));
		int user_id = (Integer) session.getAttribute("user_id");
		int playlist_id = Integer.parseInt(request.getParameter("playlist_id"));
		JSONParser parser = new JSONParser();
		
		String query1= "select user_id from user_playlist where playlist_id = ? and user_id = ?";
		String res1 = DbHelper.executeUpdateJson(query1, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT},
				new Object[] {playlist_id, user_id});
		
		if(res1 == null) {
			response.getWriter().print("ERROR: Playlist doesn't belong to user!"); 
			return ;
		}
		
		String query2= "insert into song_playlist (song_id, playlist_id) values (?, ?)";
		String res2 = DbHelper.executeUpdateJson(query2, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT},
				new Object[] {song_id, playlist_id});
		JSONObject json2 = new JSONObject();
		try {
			json2 = (JSONObject) parser.parse(res2);
		} catch (ParseException e) {
			e.printStackTrace();
		} 	
		
		response.getWriter().print(json2.toString());
	}


	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
