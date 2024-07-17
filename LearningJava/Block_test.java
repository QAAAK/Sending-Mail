public class Block_test {

    public static void main (String [] args) {

        Block b = new Block(new int[]{2,4,6});

        System.out.println(b.getSurfaceArea());
    }
}



class Block {

    public  int width;
    public  int height;

    public  int length;

    public Block (int[] arr) {

        width = arr[0];
        height = arr[2];
        length = arr[1];

    }


    public  int getWidth() {

       return width;

    }

    public  int getHeight() {

        return height;
    }

    public  int getLength () {

        return length;
    }

    public  int getVolume () {

        return width * height * length;
    }

    public  int getSurfaceArea() {

//        S = 2 (ab+bc+ac)

        return 2 * (width*height + height*length + width*length);

    }
}

