import packages from "./main.json";
import packages_deep_search_data from "./deepSearchData.json";
import packages_games from "./games.json";
import packages_gui from "./gui.json";
import packages_web from "./web.json";

import programs_github from "./programs.json";
import programs_codeberg from "./codebergPrograms.json";
import programs_gitlab from "./gitlabPrograms.json";

const programs = [
  ...programs_github,
  ...programs_codeberg,
  ...programs_gitlab,
];

export default {
  packages_games,
  packages_deep_search_data,
  packages,
  packages_gui,
  packages_web,
  programs,
};
