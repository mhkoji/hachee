;; Process-input like names are more appropriate?
(defpackage :senn.ja
  (:use :cl)
  (:export :romaji->hiragana))
(in-package :senn.ja)

(let ((rules
       '(("a" "あ") ("i" "い") ("u" "う") ("e" "え") ("o" "お")
         ("ka" "か") ("ki" "き") ("ku" "く") ("ke" "け") ("ko" "こ")
         ("sa" "さ") ("si" "し") ("su" "す") ("se" "せ") ("so" "そ")
         ("ta" "た") ("ti" "ち") ("tu" "つ") ("te" "て") ("to" "と")
         ("na" "な") ("ni" "に") ("nu" "ぬ") ("ne" "ね") ("no" "の")
         ("ha" "は") ("hi" "ひ") ("hu" "ふ") ("he" "へ") ("ho" "ほ")
         ("ma" "ま") ("mi" "み") ("mu" "む") ("me" "め") ("mo" "も")
         ("ya" "や") ("yu" "ゆ") ("yo" "よ")
         ("ra" "ら") ("ri" "り") ("ru" "る") ("re" "れ") ("ro" "ろ")
         ("la" "ぁ") ("li" "ぃ") ("lu" "ぅ") ("le" "ぇ") ("lo" "ぉ")
         ("wa" "わ") ("wi" "ゐ") ("wu" "う") ("we" "ゑ") ("wo" "を")
         ("nn" "ん")
         ("ga" "が") ("gi" "ぎ") ("gu" "ぐ") ("ge" "げ") ("go" "ご")
         ("za" "ざ") ("zi" "じ") ("zu" "ず") ("ze" "ぜ") ("zo" "ぞ")
         ("da" "だ") ("di" "ぢ") ("du" "づ") ("de" "で") ("do" "ど")
         ("ba" "ば") ("bi" "び") ("bu" "ぶ") ("be" "べ") ("bo" "ぼ")
         ("pa" "ぱ") ("pi" "ぴ") ("pu" "ぷ") ("pe" "ぺ") ("po" "ぽ")
         ("kya" "きゃ") ("kyu" "きゅ") ("kye" "きぇ") ("kyo" "きょ")
         ("sya" "しゃ") ("syu" "しゅ") ("sye" "しぇ") ("syo" "しょ")
         ("sha" "しゃ") ("shu" "しゅ") ("she" "しぇ") ("sho" "しょ")
         ("cha" "ちゃ") ("chu" "ちゅ") ("che" "ちぇ") ("cho" "ちょ")
         ("tya" "ちゃ") ("tyu" "ちゅ") ("tye" "ちぇ") ("tyo" "ちょ")
         ("nya" "にゃ") ("nyu" "にゅ") ("nye" "にぇ") ("nyo" "にょ")
         ("hya" "ひゃ") ("hyu" "ひゅ") ("hye" "ひぇ") ("hyo" "ひょ")
         ("mya" "みゃ") ("myu" "みゅ") ("mye" "みぇ") ("myo" "みょ")
         ("rya" "りゃ") ("ryu" "りゅ") ("rye" "りぇ") ("ryo" "りょ")
         ("lya" "ゃ") ("lyu" "ゅ") ("lye" "ぇ") ("lyo" "ょ")
         ("gya" "ぎゃ") ("gyu" "ぎゅ") ("gye" "ぎぇ") ("gyo" "ぎょ")
         ("zya" "じゃ") ("zyu" "じゅ") ("zye" "じぇ") ("zyo" "じょ")
         ("jya" "じゃ") ("jyu" "じゅ") ("jye" "じぇ") ("jyo" "じょ")
         ("ja" "じゃ") ("ju" "じゅ") ("je" "じぇ") ("jo" "じょ")
         ("bya" "びゃ") ("byu" "びゅ") ("bye" "びぇ") ("byo" "びょ")
         ("pya" "ぴゃ") ("pyu" "ぴゅ") ("pye" "ぴぇ") ("pyo" "ぴょ")
         ("kwa" "くゎ") ("kwi" "くぃ") ("kwe" "くぇ") ("kwo" "くぉ")
         ("tsa" "つぁ") ("tsi" "つぃ") ("tse" "つぇ") ("tso" "つぉ")
         ("fa" "ふぁ") ("fi" "ふぃ") ("fe" "ふぇ") ("fo" "ふぉ")
         ("gwa" "ぐゎ") ("gwi" "ぐぃ") ("gwe" "ぐぇ") ("gwo" "ぐぉ")
         ("dyi" "でぃ") ("dyu" "どぅ") ("dye" "でぇ") ("dyo" "どぉ")
         ("xwi" "うぃ") ("xwe" "うぇ") ("xwo" "うぉ")
         ("shi" "し") ("tyi" "てぃ") ("chi" "ち") ("tsu" "つ")
         ("ji" "じ") ("fu" "ふ") ("ye" "いぇ")
         ("va" "ヴぁ") ("vi" "ヴぃ") ("vu" "ヴ") ("ve" "ヴぇ") ("vo" "ヴぉ")
         ("xa" "ぁ") ("xi" "ぃ") ("xu" "ぅ") ("xe" "ぇ") ("xo" "ぉ")
         ("xtu" "っ") ("xya" "ゃ") ("xyu" "ゅ") ("xyo" "ょ")
         ("xwa" "ゎ") ("xka" "ヵ") ("xke" "ヶ")
         ("vv" "っv") ("xx" "っx") ("kk" "っk") ("gg" "っg") ("ss" "っs")
         ("zz" "っz") ("jj" "っj") ("tt" "っt") ("dd" "っd") ("hh" "っh")
         ("ff" "っf") ("bb" "っb") ("pp" "っp") ("mm" "っm") ("yy" "っy")
         ("rr" "っr") ("ww" "っw") ("cc" "っc")
         ("1" "１") ("2" "２") ("3" "３") ("4" "４") ("5" "５")
         ("6" "６") ("7" "７") ("8" "８") ("9" "９") ("0" "０")
         ("!" "！") ("@" "＠") ("#" "＃") ("$" "＄") ("%" "％")
         ("^" "＾") ("&" "＆") ("*" "＊") ("(" "（") (")" "）")
         ("-" "ー") ("=" "＝") ("`" "｀") ("\\" "￥") ("|" "｜")
         ("_" "＿") ("+" "＋") ("~" "￣") ("{" "｛") ("}" "｝")
         (":" "：") (";" "；") ("\"" "”") ("'" "’") ("." "。")
         ("," "、") ("<" "＜") (">" "＞") ("?" "？") ("/" "・")
         ("A" "Ａ") ("B" "Ｂ") ("C" "Ｃ") ("D" "Ｄ") ("E" "Ｅ")
         ("F" "Ｆ") ("G" "Ｇ") ("H" "Ｈ") ("I" "Ｉ") ("J" "Ｊ")
         ("K" "Ｋ") ("L" "Ｌ") ("M" "Ｍ") ("N" "Ｎ") ("O" "Ｏ")
         ("P" "Ｐ") ("Q" "Ｑ") ("R" "Ｒ") ("S" "Ｓ") ("T" "Ｔ")
         ("U" "Ｕ") ("V" "Ｖ") ("W" "Ｗ") ("X" "Ｘ") ("Y" "Ｙ")
         ("Z" "Ｚ")))
      (table (make-hash-table :test #'equal)))
  (loop for (romaji hiragana) in rules
        do (setf (gethash romaji table) hiragana))
  (defun romaji->hiragana (romaji)
    (gethash romaji table)))
