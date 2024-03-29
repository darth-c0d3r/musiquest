

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
 * Servlet implementation class RemovePlaylist
 */
@WebServlet("/RemovePlaylist")
public class RemovePlaylist extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public RemovePlaylist() {
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
		
		if(request.getParameter("playlist_id") == null) {
			response.getWriter().print("Incorrect Parameters Provided");
			return;
		}
				
		int playlist_id = Integer.parseInt(request.getParameter("playlist_id"));
		int user_id = (Integer) session.getAttribute("user_id");
		JSONParser parser = new JSONParser();
		
		JSONObject json1 = new JSONObject();
			
		String query1 = "delete from song_playlist where playlist_id = ? and exists (select * from user_playlist where"
				+ " user_id = ? and playlist_id = ? and playlist_type = 0)";
		String res1 = DbHelper.executeUpdateJson(query1, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT, DbHelper.ParamType.INT},
				new Object[] {playlist_id, user_id, playlist_id});		
		try {
			json1 = (JSONObject) parser.parse(res1);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		String query2 = "delete from user_playlist where user_id = ? and playlist_id = ? and playlist_type = 0";
		String res2 = DbHelper.executeUpdateJson(query2, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT},
				new Object[] {user_id, playlist_id});		
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
