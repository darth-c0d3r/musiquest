
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.util.List;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 * Servlet implementation class UpdateSong
 */
@WebServlet("/UpdateSong")
public class UpdateSong extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UpdateSong() {
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
		
		if(request.getParameter("song_id") == null || request.getParameter("value") == null) {
			response.getWriter().print("Incorrect Parameters Provided");
			return;
		}
				
		int song_id = Integer.parseInt(request.getParameter("song_id"));
		int user_id = (Integer) session.getAttribute("user_id");
		int value = Integer.parseInt(request.getParameter("value"));
		JSONParser parser = new JSONParser();
		
		String query1 = "update user_song set relation_type = relation_type + ? "
				+ "where song_id = ? and user_id = ?";
		String res1 = DbHelper.executeUpdateJson(query1, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT, DbHelper.ParamType.INT},
				new Object[] {value, song_id, user_id});
		JSONObject json1 = new JSONObject();
		try {
			json1 = (JSONObject) parser.parse(res1);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		if(json1.get("status").equals(false)) {
			response.getWriter().print(DbHelper.errorJson("Song entry does not exist").toString());			
		}
		
		String query2 = "select relation_type from user_song where song_id = ? and user_id = ?";		
		List<List<Object>> res2 = DbHelper.executeQueryList(query2, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT},
				new Object[] {song_id, user_id});
		
		int likes=0,dislikes=0;
		int relation_type = (Integer)res2.get(0).get(0);
		if(value>0) {
			if(relation_type == 1)
				++likes;
			if(relation_type-value == -1)
				--dislikes;
		}
		else {
			if(relation_type == -1)
				++dislikes;
			if(relation_type-value == 1)
				--likes;
		}
		
		String query3 = "update song set num_likes = num_likes + ?, num_dislikes = num_dislikes + ? where song_id = ?";
		
		String res3 = DbHelper.executeUpdateJson(query3, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT}, 
				new Object[] {likes, dislikes});
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
