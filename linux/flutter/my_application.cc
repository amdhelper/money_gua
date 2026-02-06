#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  // Prefer dark theme for GTK header bars to match app's dark UI.
  GtkSettings* settings = gtk_settings_get_default();
  if (settings != NULL) {
    g_object_set(settings, "gtk-application-prefer-dark-theme", TRUE, NULL);
  }

  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  // Always use a GTK header bar so we can apply a dark style consistently.
  gboolean use_header_bar = TRUE;
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "金钱卦");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    GtkStyleContext* header_context =
        gtk_widget_get_style_context(GTK_WIDGET(header_bar));
    gtk_style_context_add_class(header_context, "money-gua-titlebar");
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "金钱卦");
  }

  // Apply a dark style to the GTK header bar.
  GtkCssProvider* css_provider = gtk_css_provider_new();
  gtk_css_provider_load_from_data(
      css_provider,
      ".money-gua-titlebar {"
      "  background-color: #1b1b1b;"
      "  color: #e8e8e8;"
      "}"
      ".money-gua-titlebar .title { color: #e8e8e8; }"
      ".money-gua-titlebar button { color: #e8e8e8; }"
      ".money-gua-titlebar button:hover { background-color: #2a2a2a; }",
      -1,
      NULL);
  gtk_style_context_add_provider_for_screen(
      gdk_screen_get_default(), GTK_STYLE_PROVIDER(css_provider),
      GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
  g_object_unref(css_provider);

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  // 设置应用图标和窗口类名，确保任务栏显示正确图标
  gtk_window_set_icon_name(window, "money-gua");
  gtk_window_set_wmclass(window, "money_gua", "Money Gua");
  
  // 尝试从不同路径加载图标
  GError* error = NULL;
  GdkPixbuf* icon = NULL;
  
  // 尝试从系统图标主题加载
  icon = gtk_icon_theme_load_icon(gtk_icon_theme_get_default(), 
                                  "money-gua", 
                                  48, 
                                  GTK_ICON_LOOKUP_USE_BUILTIN, 
                                  &error);
  
  if (!icon) {
    // 尝试从应用资源加载
    const char* icon_paths[] = {
      "data/flutter_assets/assets/icon.png",
      "assets/icon.png",
      "/usr/share/pixmaps/money-gua.png",
      NULL
    };
    
    for (int i = 0; icon_paths[i] != NULL; i++) {
      if (error) {
        g_error_free(error);
        error = NULL;
      }
      
      icon = gdk_pixbuf_new_from_file(icon_paths[i], &error);
      if (icon) {
        break;
      }
    }
  }
  
  if (icon) {
    gtk_window_set_icon(window, icon);
    g_object_unref(icon);
  }
  
  if (error) {
    g_warning("Failed to load application icon: %s", error->message);
    g_error_free(error);
  }

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", "com.example.money_gua",
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
