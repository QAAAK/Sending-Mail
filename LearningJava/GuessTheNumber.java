import java.util.Random;
import java.util.Scanner;


public class GuessTheNumber {

    public static void main (String [] args){

        Game newgame = new Game();

        newgame.guess();

    }
}



class Game {
    Random rand = new Random();
    int num = rand.nextInt(100);

    void guess () {
        Scanner inp = new Scanner(System.in);
        int q;

       do {
           System.out.println("Угадай число :");
           q = inp.nextInt();

           if (q > num) {
               System.out.println("Меньше");
           } else if (q < num) {
               System.out.println("Больше");
           } else {
               System.out.println("Вы выиграли");
               break;
           };
       } while (q != num);

    }


}