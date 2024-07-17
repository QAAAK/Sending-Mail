import java.util.Scanner;
public class ClassTest {

    public static void main (String [] args) {

        SayHello name = new SayHello();

        name.age = 10;
        name.hello();

        System.out.print("Полных лет: " + name.age);
    }
}

class SayHello {

    int age;

    void hello(){
        System.out.print("Как тебя зовут? ");

        Scanner hello = new Scanner(System.in);
        String name = hello.nextLine();

        System.out.println("Привет, " + name);
    }
}
