package SQLQuery;

public class SQLQuery {

    private String tableName;
    private String columnName = "";
    private String query = "";
    private String columnNameOrder = "";



    public String getTableName () {

        return tableName;

    }

    public void setTableName (String tableName) {

        this.tableName = tableName;

    }


    public String getColumnName () {

        return SQLBuilder.refactoringColumns(columnName);

    }

    public void setColumnName (String columnName) {

        this.columnName += columnName + ",";

    }



    public String getQueryFrom() {


        query = " FROM " + tableName;

        return query;

    }


//    public String getQuerySelect () {
//
//
//        query = "SELECT " + SQLBuilder.refactoringColumns(this.columnName) + query;
//
//        return query;
//
//    }


//    public String getQueryGroup () {
//
//
//            query = query + " GROUP BY " + SQLBuilder.refactoringColumns(this.columnName);
//
//            return query;
//
//    }

//    public void setColumnNameOrder (String columnName) {
//
//        this.columnNameOrder += columnName + ",";
//
//    }

//    public String getColumnNameOrder () {
//
//        query = query + " ORDER BY " + SQLBuilder.refactoringColumns(this.columnNameOrder);
//
//        return query;
//
//    }

//    public void setAgainData () {
//
//        this.query = "";
//        this.tableName = "";
//        this.columnName = "";
//        this.columnNameOrder = "";
//
//    }


//    public String executeQuery () {
//
//        return query;
//
//    }







}
