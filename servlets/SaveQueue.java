

import java.io.IOException;
import java.util.List;

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
 * Servlet implementation class SaveQueue
 */
@WebServlet("/SaveQueue")
public class SaveQueue extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public SaveQueue() {
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
		
		if(request.getParameter("name") == null) {
			response.getWriter().print("Incorrect Parameters Provided");
			return;
		}
				
		String playlist_name = request.getParameter("name");
		if(playlist_name.equals("")) {
			response.getWriter().print("Enter Valid Playlist Name");
			return;
		} 
		
		int user_id = (Integer) session.getAttribute("user_id");
		JSONParser parser = new JSONParser();		
		JSONObject json1 = new JSONObject();
		String query1 = "insert into user_playlist (user_id, name) values (?, ?) returning playlist_id";
		List<List<Object>> res1 = DbHelper.executeQueryList(query1, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.STRING},
				new Object[] {user_id, playlist_name});
		
		int playlist_id = (Integer) res1.get(0).get(0);
		
		String query2 = "insert into song_playlist(song_id, playlist_id)"
				+ " select song_id, ? from song_playlist where playlist_id = "
				+ "(select playlist_id from user_playlist where user_id = ? and playlist_type = 1);";
		String res2 = DbHelper.executeUpdateJson(query2, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT},
				new Object[] {playlist_id, user_id});		
		try {
			json1 = (JSONObject) parser.parse(res2);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		response.getWriter().print(json1.toString());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
