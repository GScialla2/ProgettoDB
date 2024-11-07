import javax.swing.*;
import java.awt.*;
import java.sql.*;

public class ProgettoJDBC extends JFrame
{
    private Connection con = null;
    private final JTextArea outputTextArea;
    public ProgettoJDBC()
    {
        //Creo l'interfaccia grafica
        JFrame frame = new JFrame("Progetto JDBC GUI");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(600, 400);
        JPanel mainPanel = new JPanel(new BorderLayout());
        outputTextArea = new JTextArea();
        outputTextArea.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(outputTextArea);
        mainPanel.add(scrollPane, BorderLayout.CENTER);
        JButton executeButton = new JButton("Esegui Operazioni");
        executeButton.addActionListener(e -> {
            try {
                executeOperation();
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
        });

        mainPanel.add(executeButton, BorderLayout.SOUTH);

        frame.getContentPane().add(mainPanel);
        frame.setVisible(true);

        //Collego il driver
        try
        {
            //Carico il driver
            Class.forName("com.mysql.jdbc.Driver");
        }
        catch(java.lang.ClassNotFoundException e)
        {
            System.err.print("ClassNotFoundException:"+e.getMessage());
        }

        //Stabilisco la connessione con il database
        try
        {
            String url = "jdbc:mysql://localhost:3306/Università";
            con = DriverManager.getConnection(url, "root", "Gabriel82@");
            outputTextArea.append("Connessione effettuata\n");
        }
        catch (SQLException ex)
        {
            outputTextArea.append("SQLException:" + ex.getMessage() + "\n");
        }
    }

    //Gestisco il database
    public void executeOperation() throws SQLException
    {
        try
        {
            outputTextArea.setText("");

            //Creo lo statement
            Statement st = con.createStatement();

            //Stampa gli studenti
            String sql = "SELECT* FROM Studente";
            ResultSet rs = st.executeQuery(sql);
            int i = 1;
            while(rs.next())
            {
                int matricola = rs.getInt("Matricola");
                String nome = rs.getString("Nome");
                String cognome = rs.getString("Cognome");
                String cf = rs.getString("Cf");
                String tipoStudente = rs.getString("tipoStudente");
                int anniFuoricorso = rs.getInt("anniFuoricorso");
                outputTextArea.append("\nMatricola Studente"+ i+": "+matricola);
                outputTextArea.append("\nNome Studente"+ i+": "+nome);
                outputTextArea.append("\nCognome Studente"+ i+": "+cognome);
                outputTextArea.append("\nCF Studente"+ i+": "+cf);
                outputTextArea.append("\nTipo Studente"+ i+": "+tipoStudente);
                outputTextArea.append("\nAnniFuoriCorso Studente"+ i+": "+anniFuoricorso+"\n");
                i++;
            }

            //Inserisce una nuova iscrizione
            int n = st.executeUpdate("INSERT INTO Iscrizione(dataIscrizione,matricolaStudente,codiceAppello)"+"VALUES('2024-01-01',1,102)");
            if(n == 1)
                outputTextArea.append("\nInserimento effettuato");

            //Modifica l'iscrizione che rispetta le condizioni della clausola WHERE
            String updateString = "UPDATE Iscrizione " + "SET matricolaStudente = 3 " + "WHERE matricolaStudente = 1 AND codiceAppello = 102";
            Statement st2 = con.createStatement();
            int resultUpdate = st2.executeUpdate(updateString);
            if(resultUpdate == 1)
                outputTextArea.append("\nAggiornamneto effettuato");

            //Stampa l'iscrizione che rispetta le condizioni della clausola WHERE
            String sqlQuery = "SELECT* FROM Iscrizione WHERE matricolaStudente = ? AND codiceAppello = ?";
            int matricolaStudente = 3;
            int codiceAppello = 102;
            PreparedStatement ps = con.prepareStatement(sqlQuery);
            ps.setInt(1,matricolaStudente);
            ps.setInt(2,codiceAppello);
            ResultSet rs1 = ps.executeQuery();
            while(rs1.next())
            {
                Date dataIscrizione = rs1.getDate("dataIscrizione");
                int matricola = rs1.getInt("matricolaStudente");
                int codice = rs1.getInt("codiceAppello");
                outputTextArea.append("\nData Iscrizione:" + dataIscrizione);
                outputTextArea.append("\nMatricola Studente: " + matricola);
                outputTextArea.append("\nCodice Appello:" + codice + "\n");
            }

            //Cancella l'iscrizione che rispetta le condizioni della clausola WHERE
            String sql2 = "DELETE FROM Iscrizione WHERE matricolaStudente = 3 AND codiceAppello = 102";
            int result = st.executeUpdate(sql2);
            if(result > 0)
                outputTextArea.append("\nCancellazione effettuata");
            else
                outputTextArea.append("\n cancellare il record");

            //Cancello tutti gli oggetti creati
            rs.close();
            rs1.close();
            st.close();
            st2.close();
            con.close();
        }
        catch(SQLException ex)
        {
            System.err.println("SQLException:" + ex.getMessage());
        }
        finally
        {
            if(con != null)
                con.close();
        }
    }

    public static void main(String[] args)
    {
        SwingUtilities.invokeLater(ProgettoJDBC::new);
    }
}