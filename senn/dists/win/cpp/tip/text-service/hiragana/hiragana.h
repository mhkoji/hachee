#pragma once

#include <msctf.h>

#include <string>
#include "../../ime/stateful_im.h"


namespace senn {
namespace senn_win {
namespace text_service {
namespace hiragana {

class CompositionHolder {
public:

  CompositionHolder() : composition_(nullptr) {}

  ITfComposition *Get() {
    return composition_;
  }

  void Set(ITfComposition *c) {
    composition_ = c;
  }

private:
  ITfComposition *composition_;
};


class EditSessionImplementingIUnknown : public ITfEditSession {
public:
  // IUnknow
  HRESULT __stdcall QueryInterface(REFIID riid, void **ppvObject) {
    if (ppvObject == NULL) {
      return E_INVALIDARG;
    }
    if (IsEqualIID(riid, IID_IUnknown) ||
        IsEqualIID(riid, IID_ITfEditSession)) {
      *ppvObject = (ITfLangBarItem *)this;
    }
    else {
      *ppvObject = NULL;
      return E_NOINTERFACE;
    }
    AddRef();
    return S_OK;
  }

  ULONG __stdcall AddRef(void) {
    return ++ref_count_;
  }

  ULONG __stdcall Release(void) {
    if (ref_count_ <= 0) {
      return 0;
    }

    const ULONG count = --ref_count_;
    if (count == 0) {
      delete this;
    }
    return count;
  }

  virtual HRESULT __stdcall DoEditSession(TfEditCookie ec) = 0;

  virtual ~EditSessionImplementingIUnknown() {}

private:

  ULONG ref_count_ = 1;
};

class EditSessionEditing : public EditSessionImplementingIUnknown {
public:
  EditSessionEditing(
      const senn::senn_win::ime::views::Editing&,
      ITfContext*,
      TfGuidAtom,
      ITfCompositionSink*,
      CompositionHolder*);
  ~EditSessionEditing() override;
 
private:
  // ITfEditSession
  HRESULT __stdcall DoEditSession(TfEditCookie ec) override;

  const senn::senn_win::ime::views::Editing view_;

  ITfContext* const context_;

  const TfGuidAtom display_attribute_atom_;

  ITfCompositionSink *composition_sink_;

  CompositionHolder* const composition_holder_;
};

class EditSessionConverting : public EditSessionImplementingIUnknown {
public:
  struct DisplayAttributeAtoms {
    TfGuidAtom non_focused, focused;
  };

  EditSessionConverting(
    const senn::senn_win::ime::views::Converting&,
    ITfContext*,
    const DisplayAttributeAtoms*,
    ITfComposition*);
  ~EditSessionConverting() override;

private:
  // ITfEditSession
  HRESULT __stdcall DoEditSession(TfEditCookie ec) override;

  const senn::senn_win::ime::views::Converting view_;

  ITfContext* const context_;

  const DisplayAttributeAtoms *atoms_;

  ITfComposition* const composition_;
};

class EditSessionCommitted : public EditSessionImplementingIUnknown {
public:
  EditSessionCommitted(
      const senn::senn_win::ime::views::Committed&,
      ITfContext*,
      ITfCompositionSink*,
      CompositionHolder*);
  ~EditSessionCommitted() override;

private:
  // ITfEditSession
  HRESULT __stdcall DoEditSession(TfEditCookie ec) override;

  const senn::senn_win::ime::views::Committed view_;

  ITfContext* const context_;

  ITfCompositionSink *composition_sink_;

  CompositionHolder* const composition_holder_;
};


class HiraganaKeyEventHandler {
public:
  HiraganaKeyEventHandler(
      TfClientId,
      ITfCompositionSink*,
      ::senn::senn_win::ime::StatefulIM*,
      TfGuidAtom,
      EditSessionConverting::DisplayAttributeAtoms*);

  HRESULT OnSetFocus(BOOL fForeground);
  HRESULT OnTestKeyDown(ITfContext * pic, WPARAM wParam, LPARAM lParam, BOOL * pfEaten);
  HRESULT OnTestKeyUp(ITfContext * pic, WPARAM wParam, LPARAM lParam, BOOL * pfEaten);
  HRESULT OnKeyDown(ITfContext * pic, WPARAM wParam, LPARAM lParam, BOOL * pfEaten);
  HRESULT OnKeyUp(ITfContext * pic, WPARAM wParam, LPARAM lParam, BOOL * pfEaten);
  HRESULT OnPreservedKey(ITfContext * pic, REFGUID rguid, BOOL * pfEaten);

private:
  TfClientId client_id_;

  ITfCompositionSink *composition_sink_;

  // The input method that manages the states.
  ::senn::senn_win::ime::StatefulIM *stateful_im_;

  CompositionHolder composition_holder_;

  // Value of the style for decorating a text when editing
  TfGuidAtom editing_display_attribute_atom_;

  // Values of the style for decorating a text when converting
  const EditSessionConverting::DisplayAttributeAtoms *converting_display_attribute_atoms_;
};

} // hiragana
} // text_service
} // win
} // senn