#include <ibus.h>
#include <glib-object.h>

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <iostream>

#include "senn_ibus/engine.h"


namespace {

struct IBusSennEngineClass {
  IBusEngineClass parent;
};

IBusEngineClass *g_parent_class = NULL;

GObject *SennEngineClassConstructor(
    GType type,
    guint n_construct_properties,
    GObjectConstructParam *construct_properties) {
  return G_OBJECT_CLASS(g_parent_class)->constructor(type,
                                                     n_construct_properties,
                                                     construct_properties);
}

void SennEngineClassDestroy(IBusObject *engine) {
  IBUS_OBJECT_CLASS(g_parent_class)->destroy(engine);
}

void SennEngineClassInit(gpointer klass, gpointer class_data) {
  IBusEngineClass *engine_class = IBUS_ENGINE_CLASS(klass);

  engine_class->process_key_event = senn::ibus::engine::ProcessKeyEvent;

  g_parent_class = reinterpret_cast<IBusEngineClass*>(
      g_type_class_peek_parent(klass));

  GObjectClass *object_class = G_OBJECT_CLASS(klass);
  object_class->constructor = SennEngineClassConstructor;

  IBusObjectClass *ibus_object_class = IBUS_OBJECT_CLASS(klass);
  ibus_object_class->destroy = SennEngineClassDestroy;
}

GType GetType() {
  static GType type = 0;

  static const GTypeInfo type_info = {
    sizeof(IBusSennEngineClass),
    NULL,
    NULL,
    SennEngineClassInit,
    NULL,
    NULL,
    sizeof(senn::ibus::engine::IBusSennEngine),
    0,
    senn::ibus::engine::Init,
  };

  if (type == 0) {
    type = g_type_register_static(IBUS_TYPE_ENGINE,
                                  "IBusSennEngine",
                                  &type_info,
                                  static_cast<GTypeFlags>(0));
    if (type == 0) {
      std::cerr << "g_type_register_static failed";
      exit(1);
    }
  }

  return type;
}

void Disconnected(IBusBus *bus, gpointer user_data) {
  ibus_quit();
}

void StartEngine(bool exec_by_daemon) {
  ibus_init();

  IBusBus *bus = ibus_bus_new();
  g_signal_connect(bus, "disconnected", G_CALLBACK(Disconnected), NULL);

  {
    IBusComponent *component =
      ibus_component_new("org.freedesktop.IBus.Senn",
                         "Senn Component",
                         PACKAGE_VERSION,
                         "MIT",
                         "mhkoji",
                         "",
                         "",
                         "ibus-senn");
    ibus_component_add_engine(component,
                              ibus_engine_desc_new("senn-jp",
                                                   "Senn",
                                                   "Senn Component",
                                                   "ja",
                                                   "MIT",
                                                   "mhkoji",
                                                   "",
                                                   "default"));

    {
      IBusFactory *factory = ibus_factory_new(ibus_bus_get_connection(bus));
      ibus_factory_add_engine(factory, "senn-jp", GetType());
    }

    if (exec_by_daemon) {
      ibus_bus_request_name(bus, "org.freedesktop.IBus.Senn", 0);
    } else {
      ibus_bus_register_component(bus, component);
    }

    g_object_unref(component);
  }

  ibus_main();
}

}  // namespace


namespace {

gboolean g_option_ibus = FALSE;

const GOptionEntry g_option_entries[] = {
  { "ibus", 'i', 0, G_OPTION_ARG_NONE, &g_option_ibus,
    "component is executed by ibus", NULL },
  { NULL },
};


class ContextReleaser {
public:
  ContextReleaser(GOptionContext *context) :
    context_(context) {
  }

  ~ContextReleaser() {
    g_option_context_free(context_);
  }

private:
  GOptionContext *context_;
};

} // namespace

int main(gint argc, gchar **argv) {
  {
    GOptionContext *context =
      g_option_context_new("- ibus senn engine component");
    ContextReleaser releaser(context);

    g_option_context_add_main_entries(context, g_option_entries, "ibus-senn");
    GError *error = NULL;
    if (!g_option_context_parse(context, &argc, &argv, &error)) {
      g_print("Option parsing failed: %s\n", error->message);
      std::exit(1);
    }
  }

  StartEngine(g_option_ibus);
  return 0;
}