#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

//use asm global bitmaps to load board later
extern long long whitePawns;
// extern long long whiteBishops;
// extern long long whiteKnights;
// extern long long whiteCastles;
// extern long long whiteQueens;
// extern long long whiteKing;
//
// extern long long blackPawns;
// extern long long blackBishops;
// extern long long blackKnights;
// extern long long blackCastles;
// extern long long blackQueens;
// extern long long blackKing;

long long gui; //gui bitmap

extern long long aiPlayer;  //current player AI uses

extern ai();
extern aiMove();

/*
gcc chessGUI.c -o run `pkg-config --cflags --libs gtk+-2.0`
*/

int board[64];
GtkWidget *window;
GtkWidget *layout;
GtkWidget *image;
GtkWidget* table;
GtkWidget *button, *bMove; //butons
GtkLayout* label;
GtkEntry* entry;
char path[1024]; //img folder path
char tempPath[1024];


void addPiecesGui();

//do a move
void move(){
    printf("Moved\n");
    //ai to move
    ai();
    loadLayout();
    addPiecesGui();
    aiPlayer *= -1;
}

void createWindow(){
    //create new window
    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

    // Set the window title
    gtk_window_set_title (GTK_WINDOW (window), "Chess");

    //set window size
    gtk_window_set_default_size(
        GTK_WINDOW(window), 800, 850);

    // Create a 8x8 table
    table = gtk_table_new (1, 2, TRUE);

    layout = gtk_layout_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER (window), layout);
}

void loadLayout(){
	//refresh the layout widget
	gtk_container_remove(GTK_CONTAINER(window), layout);

    layout = gtk_layout_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER (window), layout);
	strcpy(tempPath, path);
    image = gtk_image_new_from_file(
        strcat(tempPath, "chessBoard.svg"));
    gtk_layout_put(GTK_LAYOUT(layout), image, 0, 0);

	//do the move button
	bMove = gtk_button_new_with_label("MOVE");
	gtk_widget_show(bMove);
	gtk_layout_put(GTK_LAYOUT(layout), bMove, 725,815);
    gtk_signal_connect(GTK_OBJECT(bMove), "clicked",
                       GTK_SIGNAL_FUNC(move),NULL);

    gtk_container_add(GTK_CONTAINER (layout), table);
}



static void addLabels()
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
    aiPlayer = 1;

	//get running dir put in swd
   	getcwd(path, sizeof(path));
	strcat(path, "/img/");

   	 createWindow();

	addLabels();
	loadLayout();


    //add the pieces to board
    addPiecesGui();

    // button = gtk_button_new_with_label("Print Text");
    // gtk_widget_show(button);
    // gtk_layout_put(GTK_LAYOUT(layout), button, 825, 150);
    // gtk_signal_connect(GTK_OBJECT(button), "clicked",
    //                    GTK_SIGNAL_FUNC(callback),
    //                    (gpointer)entry);

    gtk_widget_show(layout);
    gtk_widget_show_all(window);


    //close on exit
    g_signal_connect_swapped(G_OBJECT(window), "destroy",
    G_CALLBACK(gtk_main_quit), NULL);


    gtk_main ();


    return 0;
}

//add pieces to board in gui from global bitmaps
void addPiecesGui(){


    int i, j;
    //clear the board first
    for(i = 0; i<64; i++){
        board[i] = 0;
    }
    //copy over current bitMaps to temp vars
    long long guiPiece = whitePawns;

    //add all pieces to board from bitmaps
    for(i = 0; i<12; i++){
            //for bitmap of every piece type
            guiPiece = *(&whitePawns+i);
            //check for a bit on
            long long bitChecker = 0x1;
        for(j = 0; j<64;j++){
            int pieceHere = (bitChecker & guiPiece) == 0 ? 0:1;
            if(pieceHere)
                //asign piece type
                board[j] = i + 1;
            //shift bitChecker one bit left
            bitChecker <<= 1;
        }
    }

    //add images for each piece on board
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
    gtk_widget_show_all(window);
}
