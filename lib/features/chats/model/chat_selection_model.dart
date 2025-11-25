class ChatSelectionModel {
  final Set<int> selectedIndexes; 
  final bool isMultiSelection;

  ChatSelectionModel({
    this.selectedIndexes = const {},
    this.isMultiSelection = false,
  });

  bool isSelected(int index) => selectedIndexes.contains(index);

  ChatSelectionModel copyWith({
    Set<int>? selectedIndexes,
    bool? isMultiSelection,
  }) {
    return ChatSelectionModel(
      selectedIndexes: selectedIndexes ?? this.selectedIndexes,
      isMultiSelection: isMultiSelection ?? this.isMultiSelection,
    );
  }
}
