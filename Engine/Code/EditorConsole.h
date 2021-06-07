#ifndef EDITORCONSOLE_H
#define EDITORCONSOLE_H

#define _CRT_SECURE_NO_WARNINGS

#include "imgui.h"
#include "imgui_internal.h"
#include <ctype.h>

class EditorConsole
{
public:
	EditorConsole(const char* name = "null", bool startEnabled = false, ImGuiWindowFlags flags = ImGuiWindowFlags_None);
	~EditorConsole();

public:
	void PreUpdate();
	void Update();

	void ClearLog();
	void AddLog(const char* fmt, ...) IM_FMTARGS(2);

	void ExecCommand(const char* command_line);

	int TextEditCallback(ImGuiInputTextCallbackData* data);

	static int TextEditCallbackStub(ImGuiInputTextCallbackData* data) // In C++11 you are better off using lambdas for this sort of forwarding callbacks
	{
		EditorConsole* console = (EditorConsole*)data->UserData;
		return console->TextEditCallback(data);
	}

	// Portable helpers
	static int Stricmp(const char* str1, const char* str2)/* { int d; while ((d = toupper(*str2) - toupper(*str1)) == 0 && *str1) { str1++; str2++; } return d; }*/;
	static int Strnicmp(const char* str1, const char* str2, int n)/* { int d = 0; while (n > 0 && (d = toupper(*str2) - toupper(*str1)) == 0 && *str1) { str1++; str2++; n--; } return d; }*/;
	static char* Strdup(const char *str)/* { size_t len = strlen(str) + 1; void* buf = malloc(len); IM_ASSERT(buf); return (char*)memcpy(buf, (const void*)str, len); }*/;
	static void Strtrim(char* str)/* { char* str_end = str + strlen(str); while (str_end > str && str_end[-1] == ' ') str_end--; *str_end = 0; }*/;

private:
	char                  InputBuf[256];
	ImVector<char*>       Items;
	ImVector<const char*> Commands;
	ImVector<char*>       History;
	int                   HistoryPos;    // -1: new line, 0..History.Size-1 browsing history.
	ImGuiTextFilter       Filter;
	bool                  AutoScroll;
	bool                  ScrollToBottom;
};

#endif // !EDITORCONSOLE_H