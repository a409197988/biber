:: The COPY/DEL steps are so that the packed biber main script is not
:: called "biber" as on case-insensitive file systems, this clashes with
:: the Biber lib directory and generates a (harmless) warning on first run.

:: XML::LibXSLT has a workaround for LibXSLT.dll conflicting with libxslt.dll on
:: windows due to case-insensitivity. The Makefile.PL for XML::LibXSLT forces its
:: .dll to end in ".xs.dll" which avoids the conflict but breaks when packaged with pp.
:: Since strawberry perl includes its own libxslt with a non-default name, it is therefore
:: safe to use the default XML::LibXSLT .dll name which does work when packed with pp.
:: To do this, you have to install your own XML::LibXSLT in strawberry perl:
:: edit the Makefile.PL, line 195 or thereabouts and change it to:
::
::     $config{DLEXT} = 'dll' if ($is_Win32);
::
:: then build and install as usual (this seems ok with the included
:: XML::LibXSLT with strawberry perl 5.16 for some reason)

:: Have to explicitly include the Input* modules as the names of these are dynamically
:: constructed in the code so Par::Packer can't auto-detect them.
:: Same with some of the output modules.

COPY C:\strawberry\perl\site\bin\biber %TEMP%\biber-MSWIN32

SET PAR_VERBATIM=1

CALL pp ^
  --unicode ^
  --module=deprecate ^
  --module=Biber::Input::file::bibtex ^
  --module=Biber::Input::file::biblatexml ^
  --module=Biber::Output::dot ^
  --module=Biber::Output::bbl ^
  --module=Biber::Output::bblxml ^
  --module=Biber::Output::bibtex ^
  --module=Biber::Output::biblatexml ^
  --module=Pod::Simple::TranscodeSmart ^
  --module=Pod::Simple::TranscodeDumb ^
  --module=List::MoreUtils::XS ^
  --module=List::SomeUtils::XS ^
  --module=List::MoreUtils::PP ^
  --module=HTTP::Status ^
  --module=HTTP::Date ^
  --module=Encode:: ^
  --module=IO::Socket::SSL ^
  --module=File::Find::Rule ^
  --module=Text::CSV_XS ^
  --module=DateTime ^
  --link=C:\WINDOWS\system32\libbtparse.dll ^
  --link=C:\strawberry\c\bin\libxslt-1_.dll ^
  --link=C:\strawberry\c\bin\libexslt-0_.dll ^
  --link=C:\strawberry\c\bin\zlib1_.dll ^
  --link=C:\strawberry\c\bin\libxml2-2_.dll ^
  --link=C:\strawberry\c\bin\libiconv-2_.dll ^
  --link=C:\strawberry\c\bin\ssleay32_.dll ^
  --link=C:\strawberry\c\bin\libeay32_.dll ^
  --link=C:\strawberry\c\bin\liblzma-5_.dll ^
  --addlist=biber.files ^
  --cachedeps=scancache ^
  --output=biber-MSWIN32.exe ^
  %TEMP%\biber-MSWIN32

DEL %TEMP%\biber-MSWIN32
