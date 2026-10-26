using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

namespace CatchGoose
{
    public sealed partial class GooseGame
    {
        public GooseSelectionHighlight SelectionHighlight { get; private set; }
        public GooseItem CurrentSelectedItem => SelectionHighlight ? SelectionHighlight.Target : null;
        public bool PointerActive { get; private set; }
        int selectionPointer;
        readonly List<RaycastResult> selectionUiHits = new List<RaycastResult>(16);
        PointerEventData selectionUiEvent;
        EventSystem selectionEventSystem;

        public bool CanSelectItems => Playing && !Paused && !Busy && !Preparing && SpawnComplete && AppVisible && !(SurfaceShuffle && SurfaceShuffle.Active)
            && Level != null && (Level.seconds <= 0 || TimeLeft > 0) && Tray.Entries.Count < TrayRules<GooseItem>.Capacity;

        bool ValidSelection(GooseItem item) => item && !item.Picked && !item.Frozen && item.DepthVisible
            && item.gameObject.activeInHierarchy && item.SelectionCollider && item.SelectionCollider.enabled;

        bool SelectionOverUi(Vector2 position)
        {
            if (!EventSystem.current) return false;
            if (selectionUiEvent == null || selectionEventSystem != EventSystem.current)
            { selectionEventSystem = EventSystem.current; selectionUiEvent = new PointerEventData(selectionEventSystem); }
            selectionUiEvent.Reset(); selectionUiEvent.position = position;
            selectionUiHits.Clear(); EventSystem.current.RaycastAll(selectionUiEvent, selectionUiHits);
            return selectionUiHits.Count > 0;
        }

        // The nearest collider remains an occluder even when it isn't selectable.
        // Never search through a hidden object, container or an unpickable front item.
        public GooseItem FindSelectableAtScreenPosition(Vector2 position)
        {
            if (!CanSelectItems || !MainCamera.pixelRect.Contains(position)) return null;
            int n = Physics.RaycastNonAlloc(MainCamera.ScreenPointToRay(position), pickHits, 100,
                ~((1 << 2) | (1 << 8) | (1 << 27) | (1 << 28) | (1 << 29) | (1 << 30)), QueryTriggerInteraction.Ignore);
            Collider nearest = null; float distance = float.PositiveInfinity;
            for (int i = 0; i < n; i++) if (pickHits[i].distance < distance)
            { nearest = pickHits[i].collider; distance = pickHits[i].distance; }
            var item = nearest ? nearest.GetComponentInParent<GooseItem>() : null;
            return ValidSelection(item) ? item : null;
        }

        public bool BeginPointer(Vector2 position, int pointerId = 0)
        {
            if (PointerActive || !CanSelectItems || !MainCamera.pixelRect.Contains(position) || SelectionOverUi(position)) return false;
            selectionPointer = pointerId; PointerActive = true;
            SelectionHighlight.SetTarget(FindSelectableAtScreenPosition(position));
            return true;
        }

        public void MovePointer(Vector2 position, int pointerId = 0)
        {
            if (!PointerActive || pointerId != selectionPointer) return;
            if (!CanSelectItems || !MainCamera.pixelRect.Contains(position) || SelectionOverUi(position))
            { CancelPointer(); return; }
            SelectionHighlight.SetTarget(FindSelectableAtScreenPosition(position));
        }

        public bool EndPointer(Vector2 position, int pointerId = 0)
        {
            if (!PointerActive || pointerId != selectionPointer) return false;
            var item = CurrentSelectedItem;
            // The end event must never select a different object that wasn't previewed.
            bool commit = CanSelectItems && ValidSelection(item) && MainCamera.pixelRect.Contains(position)
                && !SelectionOverUi(position) && FindSelectableAtScreenPosition(position) == item;
            CancelPointer();
            return commit && Pick(item);
        }

        public void CancelPointer()
        {
            PointerActive = false;
            if (SelectionHighlight) SelectionHighlight.SetTarget(null);
        }

        public void CancelPointer(int pointerId)
        { if (PointerActive && pointerId == selectionPointer) CancelPointer(); }

        internal void InvalidateSelection(GooseItem item)
        { if (CurrentSelectedItem == item) CancelPointer(); }

        void TickSelectionInput()
        {
            if (PointerActive && (!CanSelectItems || (CurrentSelectedItem && !ValidSelection(CurrentSelectedItem)))) CancelPointer();
            if (GooseWeChatPlatform.HandlesPointer) return;
            // Native touch also avoids Unity's synthesized mouse events (double picks).
            if (Input.touchCount > 0)
            {
                for (int i = 0; i < Input.touchCount; i++)
                {
                    var t = Input.GetTouch(i);
                    switch (t.phase)
                    {
                        case TouchPhase.Began: BeginPointer(t.position, t.fingerId); break;
                        case TouchPhase.Moved: MovePointer(t.position, t.fingerId); break;
                        case TouchPhase.Ended: EndPointer(t.position, t.fingerId); break;
                        case TouchPhase.Canceled: CancelPointer(t.fingerId); break;
                    }
                }
                return;
            }
            if (Input.GetMouseButtonDown(0)) BeginPointer(Input.mousePosition, -1);
            else if (Input.GetMouseButton(0)) MovePointer(Input.mousePosition, -1);
            if (Input.GetMouseButtonUp(0)) EndPointer(Input.mousePosition, -1);
        }

        void OnApplicationFocus(bool focused) { if (!focused) CancelPointer(); }
        void OnDisable() { CancelPointer(); }
    }
}
