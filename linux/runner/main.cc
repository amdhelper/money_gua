#include "my_application.h"
#include <glib.h>

int main(int argc, char** argv) {
  // Force client-side decorations and dark GTK theme for the titlebar.
  g_setenv("GTK_CSD", "1", TRUE);
  g_setenv("GTK_THEME", "Adwaita:dark", TRUE);

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
