-----------------------------


SBVConvertor is a simple utility that is used to convert SBV format subtitle files to a
comma-delimited format that is also compatible with the STL subtitle format, such as is used
by DVD studio pro.

The upshot of this is that one can upload a video and a script to Youtube.com and allow their
automatic voice recognition-based subtitling system to create an initial draft of the timecoded
subtitle script. Then one can download this file in SBV format and covert it to a format that can
be loaded into NeoOffice, OpenOffice, or Excel, where it can be fixed. Alternatively, one could
load the converted file into DVD Studio Pro for use in DVD creation.

Basic operation is simple. Because the SBV format uses milliseconds instead of frames, a 
frame rate must be specified (this defaults to 30 frames per second). Also, a "NewLine Char" can
be specified which translates the line breaks used by the SBV file into a break character. DVD
Studio Pro uses the '|' character to force a line break in a subtitle.

The separator character between the timecodes and the subtitle text can also be specified 
(defaults to comma), and optionally quotes can be added around the subtitle text.



-----------------------------
