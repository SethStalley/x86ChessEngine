#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>


/*
gcc chessGUI.c -o run `pkg-config --cflags --libs gtk+-2.0`
*/

/* Our callback.
 * The data passed to this function is printed to stdout */

    int board[64];
    GtkWidget *window;
    GtkWidget *layout;
    GtkWidget *image;
    GtkWidget* table;
    GtkWidget* button;
    GtkLayout* label;
    GtkEntry* entry;
    char path[1024]; //img folder path
    char tempPath[1024];

void createWindow(){
    

    //create new window
    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

    // Set the window title
    gtk_window_set_title (GTK_WINDOW (window), "Chess");

    //set window size
    gtk_window_set_default_size(GTK_WINDOW(window), 1000, 800);

    // Create a 8x8 table
    table = gtk_table_new (1, 2, TRUE);

    layout = gtk_layout_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER (window), layout);
    
	strcpy(tempPath, path);
    image = gtk_image_new_from_file(strcat(tempPath, "chessBoard.svg"));
    gtk_layout_put(GTK_LAYOUT(layout), image, 0, 0);

}

void addPieces(){
    int i; 
    for(i = 0; i<64; i++){
	int position = i;
	int x = ((i%8) * 100) + 20;
	int y = (abs((i/8)-7) * 100) + 20;
	strcpy(tempPath, path);
        switch(board[i]){
        case 1:
            image = gtk_image_new_from_file(strcat(tempPath, "wpawn.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);    
            break;
        case 2:
            image = gtk_image_new_from_file(strcat(tempPath, "wbishop.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
	case 3:
            image = gtk_image_new_from_file(strcat(tempPath, "wknight.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
	case 4:
            image = gtk_image_new_from_file(strcat(tempPath, "wrook.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
	case 5:
            image = gtk_image_new_from_file(strcat(tempPath, "wqueen.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
	case 6:
            image = gtk_image_new_from_file(strcat(tempPath, "wking.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
	case 7:
            image = gtk_image_new_from_file(strcat(tempPath, "bpawn.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
	case 8:
            image = gtk_image_new_from_file(strcat(tempPath, "bbishop.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
	case 9:
            image = gtk_image_new_from_file(strcat(tempPath, "bknight.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
	case 10:
            image = gtk_image_new_from_file(strcat(tempPath, "brook.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
	case 11:
            image = gtk_image_new_from_file(strcat(tempPath, "bqueen.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
	case 12:
            image = gtk_image_new_from_file(strcat(tempPath, "bking.png"));
            gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
	    break;
        }
    }
}

static void CreateTextBox()
{
    label = gtk_label_new("Piece Selection");
    gtk_layout_put((layout), label, 825, 25);
    entry = gtk_entry_new();
    gtk_layout_put(GTK_LAYOUT(layout), entry, 825, 50);
    gtk_entry_set_max_length(entry, 4);

    label = gtk_label_new("Piece Movement");
    gtk_layout_put((layout), label, 825, 85);
    entry = gtk_entry_new();
    gtk_layout_put(GTK_LAYOUT(layout), entry, 825, 110);
    gtk_entry_set_max_length(entry, 4);
}

void callback( GtkWidget *widget,
               gpointer   data )
{
    GtkEntry* entry = (GtkEntry*)data;

    printf("on_button_clicked - entry = '%s'\n", gtk_entry_get_text(entry));
    fflush(stdout);
}

//int initGui( int   argc, char *argv[] )
int initGui(int   argc, char *argv[])
{
	//get running dir put in swd
   	getcwd(path, sizeof(path));
	strcat(path, "/img/");


    //gtk_init (&argc, &argv);
    //gtk_init (&argc, &argv);
    createWindow();
    int i;
    for(i = 0; i<64; i++){
        board[i] = 0;
    }
    board[0] = 4;
    board[1] = 3;
    board[2] = 2;
    board[3] = 5;
    board[4] = 6;
    board[5] = 2;
    board[6] = 3;
    board[7] = 4;

    board[8] = 1;
    board[9] = 1;
    board[10] = 1;
    board[11] = 1;
    board[12] = 1;
    board[13] = 1;
    board[14] = 1;
    board[15] = 1;



    board[48] = 7;
    board[49] = 7;
    board[50] = 7;
    board[51] = 7;
    board[52] = 7;
    board[53] = 7;
    board[54] = 7;
    board[55] = 7;

    board[56] = 10;
    board[57] = 9;
    board[58] = 8;
    board[59] = 12;
    board[60] = 11;
    board[61] = 8;
    board[62] = 9;
    board[63] = 10;
    addPieces();
    CreateTextBox();

    button = gtk_button_new_with_label("Print Text");
    gtk_widget_show(button);
    gtk_layout_put(GTK_LAYOUT(layout), button, 825, 150);
    gtk_signal_connect(GTK_OBJECT(button), "clicked",
                       GTK_SIGNAL_FUNC(callback),
                       (gpointer)entry);
   
    


    gtk_container_add(GTK_CONTAINER (layout), table);
    gtk_widget_show(layout);

    
    gtk_widget_show_all  (window);
    

    //close on exit
    g_signal_connect_swapped(G_OBJECT(window), "destroy",
    G_CALLBACK(gtk_main_quit), NULL);


    gtk_main ();
    
    return 0;
}
