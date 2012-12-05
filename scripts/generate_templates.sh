#!/bin/sh

./scripts/generate_base_templates.rb -o /tmp/template_build -s ./GeminiSDK -t ./templates
./scripts/generate_gemini_template.rb -o /tmp/template_build -s ./GeminiSDK ./templates/TemplateInfo.plist.gemini
./scripts/generate_lib_template.rb -o /tmp/template_build -s ./GeminiSDK ./templates/lib/TemplateInfo.plist.lib_lua
./scripts/generate_lib_template.rb -o /tmp/template_build -s ./GeminiSDK ./templates/lib/TemplateInfo.plist.lib_Gemini
./scripts/generate_lib_template.rb -o /tmp/template_build -s ./GeminiSDK ./templates/lib/TemplateInfo.plist.lib_Box2D
./scripts/generate_lib_template.rb -o /tmp/template_build -s ./GeminiSDK ./templates/lib/TemplateInfo.plist.lib_ObjectAL
