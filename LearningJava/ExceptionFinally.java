public class ExceptionFinally {

    public static void main(String [] args) {


        try {

            int[] arr = new int[3];

            arr[2] = 10;

        } catch (Throwable exc) {

            System.out.println("NO");
        } finally {

            System.out.print("Operation completed");
        }


    }

}
