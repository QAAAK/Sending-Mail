public class While {
    public static void main (String [] args) {
        int x = 0;

        while (x <= 10) {

            if (x == 4) {
                System.out.println(x +" Oh, my Birthday");
                break;
            }
            System.out.println("Number is - " + x );
            x ++;


        }
    }
}
