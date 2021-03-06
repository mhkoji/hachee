#pragma once
#include <fcitx/instance.h>
#include <string>
#include <functional>

#include "views.h"

namespace senn {
namespace fcitx {

class InputProcessor {
public:
  virtual ~InputProcessor() {}

  virtual INPUT_RETURN_VALUE ProcessInput(
      FcitxKeySym, uint32_t, uint32_t,
      std::function<void(const senn::fcitx::views::Converting*)>,
      std::function<void(const senn::fcitx::views::Editing*)>) = 0;
};

} // fcitx
} // senn
