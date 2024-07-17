public class ReturnedProc {

    public static void main (String [] args) {

        ReturnStrings ret = new ReturnStrings();
        MathLog sum = new MathLog();

        ret.name = "Дима";

        System.out.println(ret.hello());
        System.out.println(sum.sums());


    }

}


class ReturnStrings {

    String name;
    String hello () {

        return "Привет " + name;
    }
    String bye () {

        return "Пока " + name;
    }

}

class MathLog {

    int sums () {

        return 5 + 6;
    }

}