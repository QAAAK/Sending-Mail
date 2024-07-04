package RefactoringQuery;

import java.util.ArrayList;


public class RefactoringQuery {

    public static String tableName;
    public static String columns = "";
    public static boolean groupColumns = false;



    public static void getNameTable(String nameTable) {



         tableName = nameTable;

    }

    public static void getColumnName (String column) {



        columns += column + ",";

    }

    public static String refactoringColumns (String columns) {



        return columns.substring(0, columns.length()-1);


    }

    public static void groupQuery () {


        groupColumns = true;


    }


    public static String resultQuery () {


        if (groupColumns == true) {

            return "select " + refactoringColumns(columns) + " from " + tableName + " GROUP BY " + refactoringColumns(columns);
        }

        return "select " + refactoringColumns(columns) + " from " + tableName ;

    }

    public static void again () {

        tableName = "";
        columns = "";

    }
}
